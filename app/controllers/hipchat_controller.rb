require 'rest_client'
class HipchatController < ApplicationController

	def index
		return capabilities_descriptor			
	end

	def get_updates
		@data = FreshdeskConfig.find_by_attribute(:id,params[:search_id])
		message=""
		token = @data.attributes[:access_token].nil? ? get_access_token(@data.attributes[:oauth_id],@data.attributes[:secret_key]) : @data.attributes[:access_token]
		activity = get_ticket_activities(params["freshdesk_webhook"]["ticket_display_id"],@data.attributes[:freshdesk_domain],@data.attributes[:freshdesk_apikey])
		if activity.length == 1
			message = "#{activity.first['ticket_activity']['performer'].first['name']} submitted a ticket <a href=#{params["freshdesk_webhook"]["ticket_url"]}>#{params["freshdesk_webhook"]["ticket_subject"]}</a> "
		elsif activity.last["ticket_activity"].has_key? "note_content"
			message = "#{activity.last['ticket_activity']['performer'].first['name']} added a note for <a href=#{params["freshdesk_webhook"]["ticket_url"]}>#{params["freshdesk_webhook"]["ticket_subject"]}</a> "
		else
			activity_msg = activity.last["ticket_activity"]["activity"].join(",")
			message = "#{activity.last['ticket_activity']['performer'].first['name']} #{activity_msg} for <a href=#{params["freshdesk_webhook"]["ticket_url"]}>#{params["freshdesk_webhook"]["ticket_subject"]}</a>"
		end
		post_hipchat(token["access_token"],message,@data.attributes[:room_id])
	end

	private
		def capabilities_descriptor
			capabilities = { 
				"name" => "Freshdesk Hipchat Add-On", 
				"description"=> "Freshdesk Hipchat integration", 
				"key"=> "Freshdesk.hipchat.addon", 
				"vendor" => {
			    						"url" => "http://freshdesk.com",
			    						"name" => "Freshdesk"
			    					},
				"links" => {
			    						"homepage" => "http://freshdesk.com",
			    						"self" => "http://freshdesk.com"
		  							},
			  "capabilities" => {
			  	"oauth2Provider" => { 
			  		"tokenUrl" => "https://api.hipchat.com/v2/oauth/token"
			  	} , 
			    "hipchatApiConsumer" => {
			      "scopes" => [
			        "send_notification",
			        "send_message",
			        "view_group"
			      ],
			      "fromName" => "Freshdesk"
			    },
			    "installable" => {
			    	"installedUrl" => "#{ENV['DOMAIN']}/config/new",
			    	"uninstalledUrl" => "#{ENV['DOMAIN']}/config/remove",
			    	"allowRoom" => true,
			    	"allowGlobal" => false,
			    	"callbackUrl" => "#{ENV['DOMAIN']}/config/store"
			    }
			  }
			}
			render :json => capabilities.to_json
		end

		def get_access_token(oauth_id,secret_key)
			params = URI::encode("grant_type=client_credentials&scope=send_notification")
			site = RestClient::Resource.new("https://api.hipchat.com/v2/oauth/token?#{params}",oauth_id,secret_key)
			response = site.post(:content_type=>"application/json")
			@data.update_attributes(:access_token => JSON.parse(response.body)["access_token"])
			return JSON.parse(response.body)
		end

		def post_hipchat(token,message,room_id)
			begin
				json_data = {"color" => "green", "message" => message, "notify" => true, "message_format" => "html"}
				site=RestClient::Resource.new("https://api.hipchat.com/v2/room/#{room_id}/notification?auth_token=#{token}")
				response=site.post(json_data.to_json, :content_type=>"application/json")
				render :json => {"message" => "success"}
				rescue Exception => e 
					regenerated_token = get_access_token(@data.attributes[:oauth_id],@data.attributes[:secret_key])
					post_hipchat(regenerated_token["access_token"],message,room_id)
				end
		end

		def get_ticket_activities(id,domain,api_key)
			site = RestClient::Resource.new("#{domain}/helpdesk/tickets/activities/#{id}.json",api_key,"X")
			response = site.get(:content_type=>"application/json")
			return JSON.parse(response.body)
		end
end