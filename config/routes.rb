ActionController::Routing::Routes.draw do |map|

map.connect '/hipchat/get_updates/:search_id', :controller => 'hipchat', :action => 'get_updates'
map.connect '/config/remove', :controller => 'config', :action => 'remove'
map.resources :config, :collection => { :get_hipchat_rooms => :get, :verify_freshdesk_apikey => :get, :store => :post, :remove => :delete}
map.resources :hipchat, :collection => { :get_updates => :get }
end
