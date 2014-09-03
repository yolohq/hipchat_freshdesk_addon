require 'rest_client'
class ConfigController < ApplicationController

	def new
	end

	def create
		@config = FreshdeskConfig.create(params[:config])
		@secret_key = OauthConfig.find_by_attribute(:oauth_id, @config.attributes[:oauth_id])
		@config.update_attributes(:secret_key => @secret_key.attributes[:oauth_secret])
		@secret_key.destroy
		ticket_create_webhooks(@config.attributes[:id], @config.attributes[:redirect_url]) if @config.attributes[:ticket_create] == "1"
		ticket_update_webhooks(@config.attributes[:id], @config.attributes[:redirect_url]) if @config.attributes[:ticket_update] == "1"
		redirect_to @config.attributes[:redirect_url]
	end

	def verify_freshdesk_apikey
		begin
			site=RestClient::Resource.new("#{params[:domain]}/groups.json",params[:api_key],"X")
			response = site.get(:accept=>"application/json")
			resp = JSON.parse(response.body).class == Hash ? false : true
			render :json => {:authentication => resp}
		rescue Exception => e 
			render :json => {:authentication => false}
		end
	end

	def remove
		delete_webhooks(params[:redirect_url])
		config = FreshdeskConfig.find_by_attribute(:redirect_url, params[:redirect_url])
		config.destroy
		redirect_to params[:redirect_url]
	end

	def store
		OauthConfig.create(:oauth_id => params[:oauthId], :oauth_secret => params[:oauthSecret])
		render :json => {"message" => "success"}
	end

	private

		def ticket_update_webhooks(id,url)
			json_data = {"url" => "#{ENV['DOMAIN']}/hipchat/get_updates/#{id}", "name" => "ticket_update  #{Time.new}", 
									"description" => "Get freshdesk ticket updates", "event_data" => {''=>[{"name" => "ticket_action",
									"value" => "update"}]}}
			site = RestClient::Resource.new("#{@config.attributes[:freshdesk_domain]}/webhooks/subscription.json",@config.attributes[:freshdesk_apikey],"X")
			response = site.post(json_data, :content_type=>"application/json")
			if response.code == 200
				config_webhook = FreshdeskConfig.find_by_attribute(:id, id)
				webhooks = config_webhook.attributes[:webhook_ids]
				updated_webhooks = webhooks.blank? ? [JSON.parse(response.body)["id"]] : webhooks.push(JSON.parse(response.body)["id"])
				config_webhook.update_attributes(:webhook_ids => updated_webhooks)
				note_create_webhooks(id,url)
			end
		end

		def ticket_create_webhooks(id,url)
			json_data = {"url" => "#{ENV['DOMAIN']}/hipchat/get_updates/#{id}", "name" => "ticket_create  #{Time.new}",
			"description" => "Get freshdesk ticket create updates", "event_data" => {''=>[{"name" => "ticket_action",
				"value"=>"create"}]}}
			site = RestClient::Resource.new("#{@config.attributes[:freshdesk_domain]}/webhooks/subscription.json",@config.attributes[:freshdesk_apikey],"X")
			response = site.post(json_data, :content_type=>"application/json")
			if response.code == 200
				config_webhook = FreshdeskConfig.find_by_attribute(:id, id)
				webhooks = config_webhook.attributes[:webhook_ids]
				updated_webhooks = webhooks.blank? ? [JSON.parse(response.body)["id"]] : webhooks.push(JSON.parse(response.body)["id"])
				config_webhook.update_attributes(:webhook_ids => updated_webhooks)
			end
		end

		def note_create_webhooks(id,url)
			json_data = {"url" => "#{ENV['DOMAIN']}/hipchat/get_updates/#{id}", "name" => "note create  #{Time.new}", 
			"description" => "Get freshdesk note updates", "event_data" => {''=>[{"name"=>"note_action", 
				"value" => "create"}]}}
			site = RestClient::Resource.new("#{@config.attributes[:freshdesk_domain]}/webhooks/subscription.json",@config.attributes[:freshdesk_apikey],"X")
			response = site.post(json_data, :content_type=>"application/json")
			if response.code == 200
				config_webhook = FreshdeskConfig.find_by_attribute(:id, id)
				webhooks = config_webhook.attributes[:webhook_ids]
				updated_webhooks = webhooks.blank? ? [JSON.parse(response.body)["id"]] : webhooks.push(JSON.parse(response.body)["id"])
				config_webhook.update_attributes(:webhook_ids => updated_webhooks)
			end
		end

		def delete_webhooks(redirect_url)
			config = FreshdeskConfig.find_by_attribute(:redirect_url, redirect_url)
			unless config.nil?
				config.attributes[:webhook_ids].each do |id|
					site = RestClient::Resource.new("#{config.attributes[:freshdesk_domain]}/webhooks/subscription/#{id}.json",config.attributes[:freshdesk_apikey],"X")
					response = site.delete(:accept => "application/json")
				end
			end
		end

end