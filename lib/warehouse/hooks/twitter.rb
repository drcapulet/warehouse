Warehouse::Hooks.define :twitter do
  display_variable :twitter_name
  option :twitter_name, "", :as => :hidden
  option :twitter_id, "", :as => :hidden
  option :twitter_access_token, "", :as => :hidden
  option :twitter_access_secret, "", :as => :hidden
  option :digest, "Consolidate all commits into one tweet", :as => :boolean
  has_config
  
  define_view_link "Connect to Twitter", :connect
  define_controller_action :connect, <<-EOF
  begin
    @client = TwitterOAuth::Client.new(
      :consumer_key => hook.config[RAILS_ENV]['consumer_key'],
      :consumer_secret => hook.config[RAILS_ENV]['consumer_secret'],
      :token => session[:access_token],
      :secret => session[:secret_token]
    )
    request_token = @client.request_token(:oauth_callback => admin_twitter_callback_url)
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect_to request_token.authorize_url.gsub('authorize', 'authenticate')
  rescue => e
    flash[:error] = "We can't talk to Twitter right now - try again later"
    redirect_to admin_hooks_path
  end
  EOF
  
  define_controller_action :callback, <<-EOF
  begin
    @client = TwitterOAuth::Client.new(
      :consumer_key => hook.config[RAILS_ENV]['consumer_key'],
      :consumer_secret => hook.config[RAILS_ENV]['consumer_secret'],
      :token => session[:access_token],
      :secret => session[:secret_token]
    )
    @access_token = @client.authorize(
      session[:request_token],
      session[:request_token_secret],
      :oauth_verifier => params[:oauth_verifier]
    )
    if @client.authorized?
      hook.options = { "twitter_id" => @client.info['id'], "twitter_name" => (@client.info['login'] ? @client.info['login'] : @client.info['screen_name']), "twitter_access_token" => @access_token.token, "twitter_access_secret" => @access_token.secret }
      hook.save
      flash[:notice] = "Your hook has been updated successfully!"
      redirect_to admin_hooks_path
    else
      flash[:error] = "We had an error authenticating you!"
      redirect_to admin_hooks_path
    end  
  rescue => e
    flash[:error] = "We had an error connecting you!"
    redirect_to admin_hooks_path
  end
  EOF
  
  define_view_link "Reset", :reset
  define_controller_action :reset, <<-EOF
  hook.options = { "twitter_id" => "", "twitter_name" => "", "twitter_access_token" => "", "twitter_access_secret" => "" }
  hook.active = false
  hook.save
  flash[:notice] = "Your hook has been updated successfully!"
  redirect_to admin_hooks_path
  EOF
  
  help <<-EOF
  <h3>Click on the "Connect to Twitter" button to be redirected to connect using OAuth (more secure than giving us your username/password)</h3>
  EOF
  
  init do
    require 'twitter_oauth'
  end
  
  run do
    @client = TwitterOAuth::Client.new(
      :consumer_key => config[::RAILS_ENV]['consumer_key'],
      :consumer_secret => config[::RAILS_ENV]['consumer_secret'],
      :token => data['twitter_access_token'],
      :secret => data['twitter_access_secret']
    )
    if @client.authorized?
      repository = payload[:repository][:name]
      statuses = Array.new

      if data['digest'] == '1'
        commit = payload[:commits][-1]
        tiny_url = shorten_url(payload[:repository][:url] + '/commits/' + payload[:ref].split('/')[-1])
        statuses.push "[#{repository}] #{tiny_url} #{commit[:author][:name]} - #{payload[:commits].length} commits"
      else
        payload[:commits].each do |commit|
          tiny_url = shorten_url(commit[:url])
          statuses.push "[#{repository}] #{tiny_url} #{commit[:author][:name]} - #{commit[:message]}"
        end
      end
      
      statuses.each do |status|
        @client.update(status)
      end
    else
      puts "Not authorized for Twitter"
    end
  end
end