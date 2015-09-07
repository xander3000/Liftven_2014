# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Venom_session',
  :secret      => '154081d2e79e43773b4b1032a76da398f6bef05f418969c85f081b2b34ecb11ae53fa36edad0ced363499c07766b87cebe7fe0bed5fc628de7beacf03315fd53'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
