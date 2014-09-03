class OauthConfig < YamlRecord::Base

  properties :oauth_id, :oauth_secret

  adapter :local 

  source Rails.root.join("config/oauth_config")
end