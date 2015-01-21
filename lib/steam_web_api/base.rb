require "faraday"

module SteamWebApi

	class Base

		BASE_URI = 'http://api.steampowered.com'

		attr_accessor :response

		class << self
			
			def build_response(response, main_key)
				if response.status == 200
					parsed_response = JSON.parse(response.body)[main_key]
					OpenStruct.new yield(parsed_response).merge!(success: true)
				else
					OpenStruct.new(success: false)
				end
			end

		end

		def get(path, search_params={})
			Faraday.get("#{BASE_URI}#{path}", search_params.merge!(format: :json))
		end

		def parse_response
			JSON.parse(response.body)
		end

		def build_response(main_key, &block)
			self.class.build_response(response, main_key, &block)
		end

	end

	
end