require "open-uri"
require "json"

module SteamWebApi

	class Player

		attr_accessor :steam_id

		def initialize(steam_id)
			@steam_id = steam_id
		end

		# @todo check what response is for user with any game
		def owned_games(include_played_free_games: false, include_appinfo: false)
			data = JSON.parse(open(owned_games_url(include_played_free_games, include_appinfo)).read)['response']
			OpenStruct.new(count: data['game_count'], games: data['games'])
		end

		def stats_for_game(appid: nil)
			data = JSON.parse(open(stats_for_game_url(appid)).read)['playerstats']
			OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], stats: data['stats'])
		end

		private

		def owned_games_url(include_played_free_games, include_appinfo)
			base_url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{SteamWebApi.config.api_key}&steamid=#{steam_id}&format=json"
			base_url << '&include_played_free_games=1' if include_played_free_games
			base_url << '&include_appinfo=1' if include_appinfo
			base_url
		end

		def stats_for_game_url(game_id)
			"http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=#{game_id}&key=#{SteamWebApi.config.api_key}&steamid=#{steam_id}&format=json"
		end
		
	end
	
end