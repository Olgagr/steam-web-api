require "faraday"

module SteamWebApi

	class Base

		BASE_URI = 'http://api.steampowered.com'

		attr_accessor :response

		def get(path, search_params={})
			Faraday.get("#{BASE_URI}#{path}", search_params.merge!(format: :json))
		end

		def parse_response
			JSON.parse(response.body)
		end

		def build_response(main_key)
			if response.status == 200
				data = parse_response[main_key]
				OpenStruct.new(yield(data).merge!(success: true))
				# OpenStruct.new(count: data['game_count'], games: data['games'], success: true)
			else
				OpenStruct.new(success: false)				
			end	
		end

	end

	
end