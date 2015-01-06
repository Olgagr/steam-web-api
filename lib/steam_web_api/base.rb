require "faraday"

module SteamWebApi

	class Base

		BASE_URI = 'http://api.steampowered.com'

		def get(path, search_params={})
			Faraday.get("#{BASE_URI}#{path}", search_params.merge!(format: :json))
		end

	end

	
end