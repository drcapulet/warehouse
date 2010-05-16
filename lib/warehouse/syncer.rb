require 'active_record'
require 'yaml'
require 'erb'
require 'gravtastic'

RAILS_ENV ? true : (RAILS_ENV = "production")
db = (YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/../../config/database.yml")).result)[RAILS_ENV]).symbolize_keys
APP_CONFIG = (YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/../../config/warehouse.yml")).result)[RAILS_ENV]).symbolize_keys
ActiveRecord::Base.establish_connection(db)
# ActiveRecord::Base.logger = Logger.new(STDOUT)
require 'warehouse/hooks'
require 'app/models/repository'
require 'app/models/commit'
require 'app/models/change'
require 'app/models/hook'
require 'warehouse/repo'
require 'warehouse/node'
require 'progressbar'
Grit::Git.git_timeout = APP_CONFIG[:git_timeout].to_i if  APP_CONFIG[:git_timeout].to_i > 10
module Warehouse
  class Syncer
    
    def initialize(repo)
      @repo = repo
      @grit = repo.silo.grit_object
    end
    
    def self.process(repo = nil)
      Warehouse::Hooks.discover
      unless APP_CONFIG[:host] && !APP_CONFIG[:host].empty?
        puts "You need to set the host value under #{RAILS_ENV} in config/warehouse.yml"
        exit 1
      end
      if repo
        new(repo).process
      else
        Repository.all.each { |r| r.sync_revisions }
      end
    end
    
    def process
      puts @repo.name
      @heads = @grit.heads.dup.collect { |h| h.name }
      first_commits = []
      @heads.each do |branch|
        parent = @repo.synced_revision ? @repo.commits.first(:conditions => {:branch => branch}, :order => 'committed_date DESC') : nil
        before = parent
        date = parent ? (parent.committed_date + 1) : Time.utc(1970, 1, 1) #Time.parse("2010-01-01T00:37:53Z")
        # commits = commits_from_time_to_now_on_branch("Sun Jan 10 17:01:46 -0700 2010".to_time, branch)
        commits = @repo.synced_revision ? commits_from_time_to_now_on_branch(date, branch) : grit.log(branch)
        pbar = ProgressBar.new(branch, 100)
        i = 0.0
        sleep(1)
        if commits && !commits.empty?
          comms = []
          count = commits.count.to_f
          first_commits << commits.first if commits.first
          commits.reverse.each do |c|
            i += 1
            x = (i/count) * 100
            co = @repo.commits.new(
              :sha            => c.id,
              :message        => c.message,
              :name           => c.author.name,
              :email          => c.author.email,
              :branch         => branch,
              :tree           => c.tree.id,
              :committed_date => c.date,
              :parent         => parent
            )
            co.save
            begin
              create_changes_from_commit(c, co)
            rescue Grit::Git::GitTimeout => boom
              puts 'The syncer had a problem syncing, try changing the git timeout in warehouse.yml. It tried to run:'
              puts boom.bytes_read
              co.delete
              exit 1
            end
            parent = co
            comms << co
            pbar.set(x.to_i)
          end
          begin
            payload = create_payload_for_hooks(before, comms, branch)
            @repo.process_hooks(payload)
          rescue
            puts "The syncer had trouble finishing all of the post-receive hooks. Continuing."
          end
        end
        pbar.finish
      end
      if first_commits && !first_commits.empty?
        first = first_commits.first
        first_commits.each do |f|
          first = ((first.committed_date > f.committed_date) ? first : f)
        end
        @repo.synced_revision = first.id
        @repo.synced_revision_at = first.committed_date
        @repo.save
      end
      puts ''
    end
    
    protected
      def commits_from_time_to_now_on_branch(time, branch)
        grit.log(branch, '', :since => time)
        # repo.silo.revisions_to_sync(branch)
      end
      
      def grit
        @grit
      end
      
      
      ## TESTING W/O syncing
      # @repo = Repository.first
      # commits = [@repo.commits[1], @repo.commits.first]
      # before = commits.first.parent
      # ref = 'master'
      # require 'action_controller'
      # include ActionController::UrlWriter
      # default_url_options[:host] = "localhost:5060"
      def create_payload_for_hooks(before, commits, ref)
        comms = []
        commits.each do |commit|
          comms << {
            :id        => commit.sha,
            :message   => commit.message,
            :timestamp => commit.committed_date.xmlschema,
            :url       => commit_url(:repo => @repo, :id => commit.sha),
            :added     => commit.changes.added.collect { |b| b.path },
            :removed   => commit.changes.deleted.collect { |b| b.path },
            :modified  => commit.changes.modified.collect { |b| b.path },
            :moved     => commit.changes.moved.collect { |b| b.path },
            :author    => {
              :name  => commit.name,
              :email => commit.email,
              :avatar => commit.gravatar_url(:default => base_url + 'images/app/icons/member.png')
            }
          }
        end
        hash = {
          :before     => (before ? before.sha : ""),
          :after      => commits.last.sha,
          :ref        => ref,
          :commits    => comms,
          :repository => {
            :name        => @repo.name,
            :url         => repo_url(:repo => @repo),
          }
        }
        hash
      end
      
      def create_changes_from_commit(commit, commit_object)
        added_files, deleted_files, moved_files, modified_files = [], [], [], []
        commit.diffs.each do |d|
          if (d.a_path != d.b_path)
            moved_files << d
          elsif d.new_file
            added_files << d
          elsif d.deleted_file
            deleted_files << d
          else
            modified_files << d
          end
        end
        added_files.each do |added|
          c = commit_object.changes.new
          c.path = added.b_path
          c.from_path = added.a_path
          c.mode = 'A'
          c.sha = added.b_blob.id
          c.save
        end
        deleted_files.each do |deleted|
          p = Change.last(:conditions => {:sha => deleted.a_blob.id, :path => deleted.a_path, :commit_id => @repo.commits(:conditions => { :branch => commit_object.branch })})
          c = commit_object.changes.new
          c.path = deleted.b_path
          c.from_path = deleted.a_path
          c.mode = 'D'
          c.parent = p
          c.save
        end
        moved_files.each do |moved|
          p = Change.last(:conditions => {:sha => moved.a_blob.id, :path => moved.a_path, :commit_id => @repo.commits(:conditions => { :branch => commit_object.branch })})
          c = commit_object.changes.new
          c.sha = moved.b_blob.id
          c.path = moved.b_path
          c.from_path = moved.a_path
          c.mode = 'MV'
          c.parent = p
          c.sha = moved.b_blob.id
          c.save
        end
        modified_files.each do |mod|
          p = Change.last(:conditions => {:sha => mod.a_blob.id, :path => mod.a_path, :commit_id => @repo.commits(:conditions => { :branch => commit_object.branch })})
          c = commit_object.changes.new
          c.path = mod.b_path
          c.from_path = mod.a_path
          c.mode = 'M'
          c.parent = p
          c.sha = mod.b_blob.id
          c.save
        end        
        
      end
    
      def repo_url(h = {})
        "#{base_url}/#{h[:repo].to_param}"
      end
      
      def commit_url(h = {})
        repo_url(h) + "/commit/#{h[:id]}"
      end
      
      def base_url
        APP_CONFIG[:host]
      end
  end
end
def symbolize_keys
  inject({}) do |options, (key, value)|
    options[(key.to_sym rescue key) || key] = value
    options
  end
end