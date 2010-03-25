# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #### PATHS
  # returns a link to the commit passed for the current repository
  def commit_path_for_current(commit)
    commit_path(:id => commit.sha)
  end
  
  def repo_path_for_current(opt = {})
    opt.merge!(:repo => current_repository)
    repo_path(opt)
  end
  
  def tree_path_for_current(tree)
    # tree_path(:repo => current_repository, :rev => tree)
  end
  
  def hosted_url(*args)
    repository, name = extract_repository_and_args(args)
    hosted_url_for repository, send("#{name}_path", *args)
  end
  
  def hosted_url_for(repository, *args)
    unless repository.is_a?(Repository) || repository.nil?
      args.unshift repository
      repository = nil
    end
    repository ||= current_repository
    returning url_for(*args) do |path|
      path.insert 0, "/#{repository.slug}" if repository
    end
  end
  
  def extract_repository_and_args(args)
    if args.first.is_a?(Symbol)
      [nil, args.shift]
    else
      [args.shift, args.shift]
    end
  end
  
  #### TABS
  
  @@selected_attribute = %( class="selected").freeze
  def class_for(options)
    @@selected_attribute if current_page?(options)
  end
  
  def selected_navigation?(navigation)
    @@selected_attribute if current_navigation?(navigation)
  end
  
  def current_navigation?(navigation)
    @current_navigation ||= \
      if controller.controller_name == 'broswer' && controller.action_name == 'multi'
        :multi
      else
        case controller.controller_name
          when /browser|history/ then :browser
          when /commit/          then :activity
          else                        :admin
        end
      end
    @current_navigation == navigation
  end
  
  ## SRC CODE
  def highlight_source_for_node(node)
    highlight(node.mime_type, node.data)
  end
  
  ### USERS
  def avatar_for(commit)
    # img = '/images/app/icons/member.png'
    # img = user && user.avatar? ? user.avatar_path : '/images/app/icons/member.png'
    # tag('img', :src => img, :class => 'avatar', :alt => 'avatar')
    image_tag commit.gravatar_url(:default => root_url + 'images/app/icons/member.png'), :class => 'avatar', :alt => 'avatar'
  end
  
  ### TIME
  @@default_jstime_format = "%d %b, %Y %I:%M %p"
  def jstime(time, format = nil)
    content_tag 'span', time.strftime(format || @@default_jstime_format), :class => 'time' unless time.nil?
  end
  
  
end
