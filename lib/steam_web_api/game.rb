module SteamWebApi

	class Game < Base
		
		class << self

			def all
				response = Faraday.get('http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
				return response.status == 200 ? JSON.parse(response.body)['applist']['apps']: []
			end

		end

	end
	
end