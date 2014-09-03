# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hipchat_addon_session',
  :secret      => '6c06c4086d9687d69e38a89bf8fe50fd6664ce3d4adcf9783fac0cc9a62f99b68c67ab6fb29f3dede86f77cb35af4886e0de4240230bd651eda3b6b2a7f9407d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
