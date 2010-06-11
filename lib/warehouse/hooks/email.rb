Warehouse::Hooks.define :email do
  init do
    require 'pony'
  end
  
  run do
    email_conf = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'email.yml'))
    repo_name = payload[:repository][:name]
    name_with_ref = File.join(repo_name, payload[:ref])
    
    first_commit = payload[:commits].first
    next if first_commit.nil?
  
    first_commit_sha = first_commit[:id]
  
    # Shorten the elements of the subject
    first_commit_sha = first_commit_sha[0..5]
  
    first_commit_title = first_commit[:message][/^([^\n]+)/, 1]
    if first_commit_title.length > 50
      first_commit_title = first_commit_title.slice(0,50) << '...'
    end
    
    # TEXT BODY
    body = <<-EOH
Branch: #{payload[:ref]}
Home:   #{payload[:repository][:url]}

EOH
    # HTML BODY
    html_body = <<-EOH
<html>
  <body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0" bgcolor='#fff'>
  <style>
    body { font: normal 12px/1.5em "Helvetica Neue", Helvetica, "Lucida Grande", "Helvetica Neue", Arial, sans-serif; }
    div.commit-paths ul li { padding:4px; }
    div.commit-paths span.a, div.commit-paths span.m, div.commit-paths span.r, div.commit-paths span.mv, div.commit-paths span.cp { background: #7b0; color: #fff; font-size: 82%; border: 1px solid #fff; line-height: 100%; padding: 2px; font-weight: bold; font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; margin: 2px;}
    div.commit-paths span.m { background-color: #06b; }
    div.commit-paths span.mv { color: #540; background: #ca0; }
    div.commit-paths span.r { background: #c00; }
    div.commit-paths span.cp { background: #ccc; color: #333; }
  </style>
  <table width="95%" cellpadding="10" cellspacing="0" class="backgroundTable" bgcolor='#ebebeb' style="margin: 10px auto;">
    <tr bgcolor='#232C30' style="border:1px solid #232C30; border-bottom:none;">
      <td colspan="2"><h1 style="font-size:120%;margin-bottom:0;"><a href="#{payload[:repository][:url]}" style="text-decoration:none;color:#fff;">#{name_with_ref}</a></h1></td>
    </tr>
EOH
    
    payload[:commits].each do |commit|
      gitsha   = commit[:id]
      added    = commit[:added].map    { |f| ['A', f] }
      removed  = commit[:removed].map  { |f| ['R', f] }
      modified = commit[:modified].map { |f| ['M', f] }
  
      changed_paths = (added + removed + modified).sort_by { |(char, file)| file }
      html_changed_paths = changed_paths.collect { |(c, f)| "<li><span class=\"#{c.downcase}\" title=\"\">#{f}</span></li>" }.join("\n             ")
      changed_paths = changed_paths.collect { |entry| entry * '    ' }.join("\n    ")
      
      # timestamp = Date.parse(commit[:timestamp])
      timestamp = Time.parse(commit[:timestamp])
  
      body << <<-EOH
Commit: #{gitsha}
    #{commit[:url]}
Author: #{commit[:author][:name]} <#{commit[:author][:email]}>
Date:   #{timestamp} (#{timestamp.strftime('%a, %d %b %Y')})

Log Message:
-----------
#{commit[:message]}

EOH
      html_body << <<-EOH
      <tr>
        <td width="32px" valign="top" style="border-left:1px solid #ccc;"><img src="#{commit[:author][:avatar]}" width="32px" height="32px" alt="#{commit[:author][:name]}'s Avatar" style="padding: 2px; background: #fff; border: 1px solid #aaa; border-bottom: 1px solid #ccc; border-bottom: 1px solid #ccc;"/></td>
        <td style="border-right:1px solid #ccc;">
          <h3 style="font-size:120%; margin-bottom:0px;"><a href="#{commit[:url]}" style="text-decoration:none;color: #481;text-shadow: 1px 1px #f7f7f7;">#{gitsha}</a></h3>
          <h3 style="font-size:100%; margin-top:5px;">#{commit[:message]}</h3>
          
          <b>#{commit[:author][:name]} (<a href="mailto:#{commit[:author][:email]}">#{commit[:author][:email]}</a>)</b> on #{timestamp.strftime('%a, %b %d %Y at %I:%M%p %Z')}<br /> 
EOH
  
      if changed_paths.size > 0
        body << <<-EOH
  Changed paths:
    #{changed_paths}
  
  EOH
        html_body << <<-EOH
          <div class="commit-paths"><ul style="list-style:none; -webkit-padding-start: 0;">
          #{html_changed_paths}
          </ul></div>
EOH
      end
      
      html_body << <<-EOH
        </td>
      </tr>
      <tr><td colspan="2" style="border-left:1px solid #ccc;border-right:1px solid #ccc;"><hr width="95%" style="border-left:none;" /></td></tr>
EOH
    end # end that loop
    html_body << <<-EOH
      <tr><td colspan="2" style="border-left:1px solid #ccc;border-right:1px solid #ccc; border-bottom:1px solid #ccc;text-align:center;"><small>sent at #{Time.now}</small></td></tr>
EOH
  # 
  #   message = TMail::Mail.new
  #   message.set_content_type('text', 'plain', {:charset => 'UTF-8'})
  #   message.to      = data['address']
  #   message.subject = "[#{name_with_owner}] #{first_commit_sha}: #{first_commit_title}"
  #   message.body    = body
  #   message.date    = Time.now
  # 
  #   smtp_settings  = [ email_conf['address'], (email_conf['port'] || 25), (email_conf['domain'] || 'localhost.localdomain') ]
  #   smtp_settings += [ email_conf['user_name'], email_conf['password'], email_conf['authentication'] ] if email_conf['authentication']
  # 
  #   Net::SMTP.start(*smtp_settings) do |smtp|
  #     smtp.send_message message.to_s, "GitHub <noreply@github.com>", data['address']
  #   end
    data["emails"].each do |e|
      opts = {
        :to     => e,
        :from   => email_conf['from'],
        :via    => email_conf['via'],
        :subject => "[#{repo_name}/#{payload[:ref]}] #{first_commit_sha}: #{first_commit_title}",
        :body   => body,
        :html_body => html_body
      }
      opts[:via_options] = email_conf['via_options'].symbolize_keys if email_conf['via_options']
      Pony.mail(opts)
    end
  end
end

def symbolize_keys
  inject({}) do |options, (key, value)|
    options[(key.to_sym rescue key) || key] = value
    options
  end
end
