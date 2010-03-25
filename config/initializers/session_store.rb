# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_warehouse_session',
  :secret      => 'bfabd8970515426258f4d959e11bbe37d9d2dadef49168ff6a1b2bd58f2d715938d0ccc08bf7d2aec8edf025b29c6f08cce133bf1a876d72a8572772c3734cbb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
