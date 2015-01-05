module SteamWebApi

	class Base
		
		def build(base_url, search_params={})
				"http://api.steampowered.com/#{base_url}?format=json&#{search_params.map { |k,v| "#{k}=#{v}" }.join('&') }"
		end
		
	end

	
end