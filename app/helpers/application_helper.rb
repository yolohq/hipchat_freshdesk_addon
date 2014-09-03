# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def get_hipchat_domain url
		url_split = url.split("/")
		domain = url_split[0] + "//" + url_split[2]
	end

	def get_room_id url
		url.split("/").last.partition('?').first
	end

	def get_oauth_id url
		url.split("/").last.partition('=').last
	end

	def get_redirect_url url
		url.split("?").first
	end

end
