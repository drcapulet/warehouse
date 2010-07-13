class Notifier < ActionMailer::Base
  default_url_options[:host] = WH_CONFIG[:host].gsub(/http:\/\//, '') || 'localhost'
   
  def password_reset_instructions(user)  
    subject       "Password Reset Instructions"
    from          "Warehouse"
    recipients    user.email
    sent_on       Time.now
    content_type  'text/html'
    body          :reset_url => reset_pw_url(user.perishable_token)  
  end
end
