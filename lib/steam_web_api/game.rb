module SteamWebApi

	class Game < Base

		attr_reader :game_id

		def initialize(game_id)
			@game_id = game_id	
		end
		
		class << self

			def all
				response = Faraday.get('http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
				build_response(response, 'applist') { |data| { games: data['apps'] } }	
			end

		end

		def schema
			@response = get('/ISteamUserStats/GetSchemaForGame/v2', appid: game_id, key: SteamWebApi.config.api_key)
			build_response('game') { |data| { name: data['gameName'], version: data['gameVersion'], achievements: data['availableGameStats']['achievements'], stats: data['availableGameStats']['stats'] } }
		end

		def achievement_percentages
			@response = get('/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002', gameid: game_id)
			build_response('achievementpercentages') { |data| { achievements: data['achievements'] } }
		end

		def news(count: 3, max_length: 300)
			@response = get('/ISteamNews/GetNewsForApp/v0002', appid: game_id, count: count, maxlength: max_length)
			build_response('appnews') { |data|{ app_id: data['appid'], news_items: data['newsitems'] } }
		end

	end
	
end