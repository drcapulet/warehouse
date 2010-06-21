Warehouse::Hooks.define :basecamp do
  option :url, "Your Basecamp URL", :label => 'URL'
  option :api_key, "Your Basecamp API Key", :label => 'API Key'
  option :project, "The name of the project that you want to post the message into."
  option :category, "The name of the category that you want to post the message using."
  option :ssl, "", :as => :boolean, :label => "SSL"
  
  init do
    require 'basecamp'
  end
  
  run do
    repository      = payload[:repository][:name]
    branch          = payload[:ref].split('/').last
    
    Basecamp.establish_connection!(data['url'], data['api_key'], 'X', data['ssl'])
    project_id  = Basecamp::Project.find(:all).select { |p| p.name.downcase == data['project'].downcase }.first.id
    category_id = Basecamp::Category.find(:all, :params => { :project_id => project_id }).select { |category| category.name.downcase == data['category'].downcase }.first.id
  
    payload[:commits].each do |commit|
      gitsha        = commit[:id]
      short_git_sha = gitsha[0..5]
      timestamp     = Date.parse(commit[:timestamp])
  
      added         = commit[:added].map    { |f| ['background: #7b0; color: #fff;', f] }
      removed       = commit[:removed].map  { |f| ['background: #c00; color: #fff;', f] }
      modified      = commit[:modified].map { |f| ['background: #06b; color: #fff;', f] }
      changed_paths = (added + removed + modified).sort_by { |(char, file)| file }
      changed_paths = changed_paths.collect { |(s,f)| "<li><span style=\"#{s} font-size: 82%; border: 1px solid #fff; line-height: 100%; padding: 2px; font-weight: bold; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; margin: 2px;\">#{f}</span></li>" }.join("\n  ")
  
      # Shorten the elements of the subject
      commit_title = commit[:message][/^([^\n]+)/, 1]
      if commit_title.length > 50
        commit_title = commit_title.slice(0,50) << '...'
      end
  
      title = "Commit on #{repository}/#{branch}: #{short_git_sha}: #{commit_title}"
  
      body = <<-EOH
  *Author:* #{commit[:author][:name]} <#{commit[:author][:email]}> <br />
  *Commit:* <a href="#{commit[:url]}">#{gitsha}</a> <br />
  *Date:*   #{timestamp} (#{timestamp.strftime('%a, %d %b %Y')}) <br />
  *Branch:* #{branch} <br />
  *Home:*   #{payload[:repository][:url]} <br />
  
  <h2>Log Message</h2>
  
  <pre>#{commit[:message]}</pre>
  EOH
  
      if changed_paths.size > 0
        body << <<-EOH
  
  <h2>Changed paths</h2>
  
  <ul style="list-style:none; list-style-type:none; -webkit-padding-start: 0;">
  #{changed_paths}
  </ul>
  EOH
      end
  
       Basecamp::Message.create(:project_id => project_id, :title => title, :body => body, :category_id => category_id)
    end
  end
end
