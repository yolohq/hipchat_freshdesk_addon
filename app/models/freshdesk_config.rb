class FreshdeskConfig < YamlRecord::Base
  # Declare your properties
  properties :freshdesk_domain, :freshdesk_apikey, :hipchat_domain, :room_id, :oauth_id, :secret_key,
  					 :access_token, :ticket_create, :ticket_update, :webhook_ids, :redirect_url

  adapter :local 

  source Rails.root.join("config/freshdesk_config")
end