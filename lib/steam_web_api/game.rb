module SteamWebApi

	class Game < Base

		attr_reader :game_id

		def initialize(game_id)
			@game_id = game_id	
		end
		
		class << self

			def all
				response = Faraday.get('http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
				return response.status == 200 ? JSON.parse(response.body)['applist']['apps']: []
			end

		end

		def schema
			response = get('/ISteamUserStats/GetSchemaForGame/v2', appid: game_id, key: SteamWebApi.config.api_key)
			if response.status == 200
				data = JSON.parse(response.body)['game']
				OpenStruct.new(name: data['gameName'], version: data['gameVersion'], achievements: data['availableGameStats']['achievements'], stats: data['availableGameStats']['stats'], success: true)
			else
				OpenStruct.new(achievements: [], stats: [], success: false)
			end	
		end

		def achievement_percentages
			response = get('/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002', gameid: game_id)
			if response.status == 200
				data = JSON.parse(response.body)['achievementpercentages']
				OpenStruct.new(achievements: data['achievements'], success: true)
			else	
				OpenStruct.new(achievements: [], success: false)
			end 
		end

		def news(count: 3, max_length: 300)
			response = get('/ISteamNews/GetNewsForApp/v0002', appid: game_id, count: count, maxlength: max_length)
			if response.status == 200
				data = JSON.parse(response.body)['appnews']
				OpenStruct.new(app_id: data['appid'], news_items: data['newsitems'], success: true)
			else
				OpenStruct.new(news_items: [], success: false)
			end
		end

	end
	
end