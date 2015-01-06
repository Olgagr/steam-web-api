module SteamWebApi

	class Player < Base

		attr_accessor :steam_id

		def initialize(steam_id)
			@steam_id = steam_id
		end

		# @todo check what response is for user with any game
		def owned_games(options={})
			response = get('/IPlayerService/GetOwnedGames/v0001', owned_games_options(options))
			if response.status == 200
				data = JSON.parse(response.body)['response']
				OpenStruct.new(count: data['game_count'], games: data['games'], success: true)
			else
				OpenStruct.new(count: 0, games: [], success: false)				
			end	
		end

		def stats_for_game(app_id)
			response = get('/ISteamUserStats/GetUserStatsForGame/v0002', stats_for_game_options(app_id))
			if response.status == 200 
				data = JSON.parse(response.body)['playerstats']
				OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], stats: data['stats'], success: true)
			else
				OpenStruct.new(steam_id: nil, game_name: nil, achievements: [], stats: [], success: false)		
			end
		end

		def achievements(app_id, options={})
			response = get('/ISteamUserStats/GetPlayerAchievements/v0001', achievements_options(app_id, options))
			data = JSON.parse(response.body)['playerstats']
			if response.status == 200
				OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], success: data['success'])
			else
				OpenStruct.new(steam_id: nil, game_name: nil, achievements: [], success: false)
			end
		end

		private

		def owned_games_options(options)
			options.each { |k, v| options[k] = v ? 1 : 0 }
			{ key: SteamWebApi.config.api_key, steamid: steam_id }.merge!(options)
		end

		def stats_for_game_options(game_id)
			{ appid: game_id, key: SteamWebApi.config.api_key, steamid: steam_id }
		end

		def achievements_options(game_id, options)
			{ appid: game_id, key: SteamWebApi.config.api_key, steamid: steam_id }.merge!(options)
		end
		
	end
	
end