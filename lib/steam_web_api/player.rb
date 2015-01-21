module SteamWebApi

	class Player < Base

		attr_accessor :steam_id

		def initialize(steam_id)
			@steam_id = steam_id
		end

		class << self

			def summary(*ids)
				response = Faraday.get('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002', options(ids))
				build_response(response, 'response') { |data| { players: data['players'] } }
			end

			def bans(*ids)
				response = Faraday.get('http://api.steampowered.com/ISteamUser/GetPlayerBans/v1', options(ids))
				build_response(response, 'players') { |data| { players: data } }
			end

			private

			def options(*ids)
				{ key: SteamWebApi.config.api_key, steamids: ids.join(',') }
			end

		end

		def owned_games(options={})
			@response = get('/IPlayerService/GetOwnedGames/v0001', owned_games_options(options))
			build_response('response') { |data| { count: data['game_count'], games: data['games'] } }
		end

		def stats_for_game(app_id)
			@response = get('/ISteamUserStats/GetUserStatsForGame/v0002', stats_for_game_options(app_id))
			build_response('playerstats') { |data| { steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], stats: data['stats'] } }
		end

		def achievements(app_id, options={})
			@response = get('/ISteamUserStats/GetPlayerAchievements/v0001', achievements_options(app_id, options))
			build_response('playerstats') { |data| { steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'] } }
		end

		def summary
			data = self.class.summary(steam_id)
			get_first_data(data) { |data| { profile: data.players.first } }
		end

		def friends(relationship='all')
			@response = get('/ISteamUser/GetFriendList/v0001', friends_list_options(relationship))
			build_response('friendslist') { |data| { friends: data['friends'] } }
		end

		def recently_played_games(count=nil)
			@response = get('/IPlayerService/GetRecentlyPlayedGames/v0001', recent_games_options(count))
			build_response('response') { |data| { games: data['games'], total_count: data['total_count'] } }
		end

		def playing_shared_game(app_id)
			@response = get('/IPlayerService/IsPlayingSharedGame/v0001', shared_game_options(app_id))
			build_response('response') { |data| { lender_steamid: data['lender_steamid'] } }
		end

		def bans
			data = self.class.bans(steam_id)
			get_first_data(data) { |data| { bans: data.players.first } }
		end

		private

		def get_first_data(data)
			if data.success && data.players.size > 0
				OpenStruct.new yield(data).merge!(success: true)
			else
				OpenStruct.new(success: false)
			end
		end

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