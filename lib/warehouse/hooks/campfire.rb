Warehouse::Hooks.define :campfire do
  option :subdomain, "Your campfire subdomain (ie 'your-subdomain' if you visit 'http://your-subdomain.campfirenow.com')"
  option :room, "The name of the room this message will be posted in to"
  option :token, "Your API token"
  option :ssl, "Use SSL for the connection?", :as => :boolean, :label => "SSL"
  option :play_sound, "Play a sound when the messages are added to the room", :as => :boolean, :label => 'Play Sound'
  
  init do
    require 'tinder'
  end
  
  run do
    # fail fast with no token
    next if data['token'].to_s == ''

    repository = payload[:repository][:name]
    branch     = payload[:ref].split('/').last
    commits    = payload[:commits]
    next if commits.empty?
    campfire   = Tinder::Campfire.new(data['subdomain'], :token => data['token'], :ssl => data['ssl'].to_i == 1)
    play_sound = data['play_sound'].to_i == 1

    next unless room = campfire.find_room_by_name(data['room'])
    
    prefix = "[#{repository}/#{branch}]"
    if commits.size > 1
      messages =
        commits.map do |commit|
          short = commit[:message].split("\n", 2).first
          short += ' ...' if short != commit[:message]
          "#{prefix} #{short} - #{commit[:author][:name]}"
        end
      before, after = payload[:before][0..6], payload[:after][0..6]
      url = payload[:repository][:url] + "/commits/#{branch}"
      summary = "#{prefix} commits #{before}...#{after}: #{url}"
      messages << summary
    else
      commit = commits.first
      short = commit[:message].split("\n", 2).first
      short += ' ...' if short != commit[:message]
      messages = ["#{prefix} #{short} - #{commit[:author][:name]} (#{commit[:url]})"]
    end
    
    messages.each { |line| room.speak line }
    room.play "rimshot" if play_sound
    
    # room.leave
  end
end
