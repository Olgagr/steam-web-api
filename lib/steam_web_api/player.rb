require "open-uri"
require "json"

module SteamWebApi

	class Player

		attr_accessor :steam_id

		def initialize(steam_id)
			@steam_id = steam_id
		end

		# @todo check what response is for user with any game
		def owned_games(options={})
			data = JSON.parse(open(owned_games_url(options)).read)['response']
			OpenStruct.new(count: data['game_count'], games: data['games'])
		end

		def stats_for_game(appid)
			data = JSON.parse(open(stats_for_game_url(appid)).read)['playerstats']
			OpenStruct.new(steam_id: data['steamID'], game_name: data['gameName'], achievements: data['achievements'], stats: data['stats'])
		end

		private

		def owned_games_url(options)
			base_url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{SteamWebApi.config.api_key}&steamid=#{steam_id}&format=json"
			base_url << options.map { |k, v| "&#{k}=#{v ? 1 : 0}" }.join
			base_url
		end

		def stats_for_game_url(game_id)
			"http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=#{game_id}&key=#{SteamWebApi.config.api_key}&steamid=#{steam_id}&format=json"
		end
		
	end
	
end