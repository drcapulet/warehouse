Warehouse::Hooks.define :post_receive do
  init do
    require 'uri'
    require 'net/http'
    require 'net/https'
  end  
  
  run do
    data['urls'].each do |url|   
      Net::HTTP.post_form(URI.parse(url), { "payload" => payload.to_json })
    end
  end
end