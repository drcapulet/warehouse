module BrowserHelper
  def link_to_node(text, node, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    link_to text, url_for_node(node, args.first), options
  end

  def url_for_node(node, rev = nil)
    paths = node.respond_to?(:paths) ? node.paths : node.to_s.split('/')
    rev = rev ? rev.to_s : params[:rev]
    rev ? tree_path(:paths => paths, :rev => rev) : repo_path_for_current(:paths => paths)
  end
  
  def link_to_text_for_node(node)
    text_path(:repo => current_repository, :paths => node.paths)
  end
  
  def link_to_raw_for_node(node)
    raw_path(:repo => current_repository, :paths => node.paths, :rev => params[:rev] || 'master')
  end
  
  def link_to_blame(node)
    blame_path(:repo => current_repository, :paths => node.paths)
  end
  
  def link_to_history(node, tree = 'master')
    history_path(:repo => current_repository, :tree => tree, :paths => node.paths)
  end
  
  @@default_time = Time.utc(1970, 1, 1)
  def latest_revision_for_node(node)
    if c = Change.last(:conditions => ["path LIKE ? AND commit_id IN(?) ", node.path + '%', @repo.commits.all(:conditions => { :branch => current_commit.branch, :committed_date => @@default_time..current_commit.committed_date.utc }) ])
      c.commit
    else
      if WH_CONFIG[:commits_whenever]
        b = node.latest_revision(current_commit.committed_date + 1.second)
        Commit.new(:sha => b.id, :message => b.message, :name => b.author.name, :email => b.author.email, :branch => current_commit.branch, :tree => b.tree.id, :committed_date => b.date)
      else
        Commit.new
      end
    end
  end
  
  def link_to_crumbs(path, rev = nil)
    pieces    = path.split '/'
    name      = pieces.pop
    home_link = %(<li#{' class="crumb-divide-last"' if pieces.size == 0 && !name.nil?}>#{link_to("~ @ " + current_commit.branch, (@text_revision ? tree_path(:rev => @text_revision) : repo_path_for_current))}</li>)
    # home_link = %(<li#{' class="crumb-divide-last"' if pieces.size == 0 && !name.nil?}>#{link_to '~', hosted_url(rev ? :rev_browser : :browser)}</li>)
    return home_link unless name
    prefix = ''
    crumbs = []
    pieces.each_with_index do |piece, i|
      # crumbs << %(<li#{' class="crumb-divide-last"' if pieces.size == i+1}>#{link_to_node(piece, "#{prefix}#{piece}", rev)}</li>)
      crumbs << %(<li#{' class="crumb-divide-last"' if pieces.size == i+1}>#{link_to_node(piece, "#{prefix}#{piece}", rev)}</li>)
      prefix << piece << '/'
    end
    crumbs.unshift(home_link).join << %(<li id="current">#{name}</li>)
  end
  
  def css_class_for(node)
    node.dir? ? 'folder' : CSS_CLASSES[File.extname(node.name)] || 'file'
  end  
  
  
  # Test with
  # require 'grit'
  # t = Repository.first.full_tree
  # include BrowserHelper
  # puts html_for_repo_tree(t)
  def html_for_repo_tree(tree, level = 0, path = '')
    html = []  
    level += 1
    html << %(#{"\t" * level}<ul>\n) if level == 1
    tree.each do |a|
      # case a.class
      #   when String   then html << %(<li>#{a}</li>)
      #   when Hash     then a.each { |k, v| html << %(<li>#{k}</li><ul>#{html_for_repo_tree(v)}</ul>) }
      #   when Array    then a.each { |b| html << %(<li>#{a}</li>) }
      # end
      if a.is_a?(String)
        html << %(#{tab_level(level)}<li class="file"><a href="#" path="#{path}/#{a}">#{a}</a></li>\n)
      elsif a.is_a?(Hash)
        a.each { |k, v| html << %(#{tab_level(level)}<li class="tree"><a href="#">#{k}</a></li>\n#{tab_level(level)}<ul #{ 'style="display:none;"' unless level == 0 }>\n#{html_for_repo_tree(v,level,path + "/" + k)}\n#{tab_level(level)}</ul>\n) }
      elsif a.is_a?(Array) 
        a.each { |b| html << %(#{tab_level(level)}<li class="file"><a href="#" path="#{path}/#{a}">#{a}</a></li>\n) }
      end
    end
    html << %(#{"\t" * level}</ul>) if level == 1
    html
  end
  
  def html_list_for_branches(branches, type)
    # html = []
    # br = params[:branch] || params[:tree]
    # html << %(<ul>)
    # branches.each do |b|
    #   if br == b.name
    #     html << %(<li><strong>#{b.name} &#x2713;</strong></li>)
    #   else
    #     link = case type
    #       when :branch then  
    #       when :tag then ''
    #     end
    #     html << %(<li>#{link_to b.name, link }</li>)
    #   end
    # end
    # html << %(</ul>)
  end
  
  # def current_revision
    # @current_revision ||= current_repository.latest_commit_for_branch(@revision)
  # end
  
  ### BLAME
  def blame_for(node, revision)
    b = []
    previous = nil
    blame = node.blame(revision)
    blame.lines.each do |line|
      b << %(<tr#{ ' class="start-line"' if !previous.nil? && previous != line.commit}>)
      b << %(<td nowrap=""><pre>#{link_to truncate(line.commit.sha, :length => 8, :omission => ''), commit_path(:repo => current_repository, :id => line.commit.sha) unless previous == line.commit}</pre></td>)
      b << %(<td nowrap="" class="name"><pre>#{h(line.commit.committer.name) unless previous == line.commit }</pre></td>)
      b << %(<td nowrap="" class="time"><pre>#{line.commit.date.strftime('%Y-%m-%d') unless previous == line.commit}</pre></td>)
      b << %(<td nowrap=""><pre>#{truncate(line.commit.message, :length => 25) unless previous == line.commit}</pre></td>)
      b << %(<td nowrap="" class="lineno">#{line.lineno}</td>)
      b << %(<td nowrap="" class="src">#{code_highlight(node.mime_type, line.line, false)}</td>)
      b << %(</tr>)
      previous = line.commit
    end
    b
  end
  
  protected
    def tab_level(l)
      "\t" * l
    end
end
