require "open-uri"
require "json"

module SteamWebApi

	class Player < Base

		attr_accessor :steam_id

		def initialize(steam_id)
			@steam_id = steam_id
		end

		# @todo check what response is for user with any game
		def owned_games(options={})
			data = JSON.parse(open(owned_games_url(options)).read)['response']
			OpenStruct.new(count: data['game_count'], games: data['games'])
		end

		def stats_for_game(app_id)
			data = JSON.parse(open(stats_for_game_url(app_id)).read)['playerstats']
			OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], stats: data['stats'], success: true)
		rescue OpenURI::HTTPError => e
			OpenStruct.new(steam_id: nil, game_name: nil, achievements: [], stats: [], success: false, error: e.message)		
		end

		def achievements(app_id, options={})
			data = JSON.parse(open(achievements_url(app_id, options)).read)['playerstats']
			OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], success: data['success'])
		rescue OpenURI::HTTPError => e
			OpenStruct.new(steam_id: nil, game_name: nil, achievements: [], success: false, error: e.message)
		end

		private

		def owned_games_url(options)
			options.each { |k, v| options[k] = v ? 1 : 0 }
			build 'IPlayerService/GetOwnedGames/v0001', { key: SteamWebApi.config.api_key, steamid: steam_id }.merge!(options)
		end

		def stats_for_game_url(game_id)
			build 'ISteamUserStats/GetUserStatsForGame/v0002', appid: game_id, key: SteamWebApi.config.api_key, steamid: steam_id
		end

		def achievements_url(game_id, options)
			build 'ISteamUserStats/GetPlayerAchievements/v0001', { appid: game_id, key: SteamWebApi.config.api_key, steamid: steam_id }.merge!(options)
		end
		
	end
	
end