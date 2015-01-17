module SteamWebApi

	class Player < Base

		attr_accessor :steam_id

		def initialize(steam_id)
			@steam_id = steam_id
		end

		class << self

			def summary(*ids)
				response = Faraday.get('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002', summary_options(ids))
				if response.status == 200
					data = JSON.parse(response.body)['response']
					OpenStruct.new(players: data['players'], success: true)
				else
					OpenStruct.new(players: [], success: false)
				end
			end

			private

			def summary_options(*ids)
				{ key: SteamWebApi.config.api_key, steamids: ids.join(',') }
			end

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
				OpenStruct.new(achievements: [], stats: [], success: false)		
			end
		end

		def achievements(app_id, options={})
			response = get('/ISteamUserStats/GetPlayerAchievements/v0001', achievements_options(app_id, options))
			data = JSON.parse(response.body)['playerstats']
			if response.status == 200
				OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], success: data['success'])
			else
				OpenStruct.new(achievements: [], success: false)
			end
		end

		def summary
			data = self.class.summary(steam_id)
			if(data.success && data.players.size > 0)
				OpenStruct.new(profile: data.players.first, success: true)
			else
				OpenStruct.new(profile: {}, success: false)
			end
		end

		def friends(relationship='all')
			response = get('/ISteamUser/GetFriendList/v0001', friends_list_options(relationship))
			if response.status == 200
				data = JSON.parse(response.body)['friendslist']
				OpenStruct.new(friends: data['friends'], success: true)
			else
				OpenStruct.new(friends: [], success: false)
			end
		end

		def recently_played_games(count=nil)
			response = get('/IPlayerService/GetRecentlyPlayedGames/v0001', recent_games_options(count))
			if response.status == 200
				data = JSON.parse(response.body)['response']
				OpenStruct.new(games: data['games'], total_count: data['total_count'], success: true)
			else
				OpenStruct.new(games: [], total_count: 0, success: false)
			end
		end

		def playing_shared_game(app_id)
			response = get('/IPlayerService/IsPlayingSharedGame/v0001', shared_game_options(app_id))
			if response.status == 200
				data = JSON.parse(response.body)['response']
				OpenStruct.new(lender_steamid: data['lender_steamid'], success: true)
			else
				OpenStruct.new(success: false)
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

		def friends_list_options(relationship)
			{ key: SteamWebApi.config.api_key, steamid: steam_id, relationship: relationship }
		end

		def recent_games_options(count)
			{ key: SteamWebApi.config.api_key, steamid: steam_id, count: count }	
		end

		def shared_game_options(app_id)
			{ key: SteamWebApi.config.api_key, steamid: steam_id, appid_playing: app_id }
		end
		
	end
	
end