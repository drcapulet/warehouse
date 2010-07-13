EMAIL_CONFIG = (YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/../../config/email.yml")).result)).symbolize_keys
if EMAIL_CONFIG[:via] == :smtp
  ActionMailer::Base.delivery_method = :smtp
  hash = {
    :address => EMAIL_CONFIG[:via_options]['host'],
    :port => EMAIL_CONFIG[:via_options]['port'],
    :domain => EMAIL_CONFIG[:via_options]['domain']
  }
  hash.merge!({
    :username => EMAIL_CONFIG[:via_options]['username'],
    :password => EMAIL_CONFIG[:via_options]['password'],
    :authentication => EMAIL_CONFIG[:via_options]['auth'] || :plain
  }) if (EMAIL_CONFIG[:via_options]['username'] && EMAIL_CONFIG[:via_options]['password'])
  ActionMailer::Base.smtp_settings = hash
elsif EMAIL_CONFIG[:via] == :sendmail
  ActionMailer::Base.delivery_method = :sendmail
  ActionMailer::Base.sendmail_settings = {
    :location => (EMAIL_CONFIG[:via_options]['location'] || `which sendmail`),
    :arguments => '-i -t'
  }
end