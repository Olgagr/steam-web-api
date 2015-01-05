require "spec_helper"

RSpec.describe SteamWebApi::Player do

	let(:player) { SteamWebApi::Player.new('12345') }

	before do
	  SteamWebApi.configure do |config|
	  	config.api_key = '12'
	  end
	end

	describe '#owned_games' do

		before do
		  stub_request(:get, 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001?format=json&key=12&steamid=12345')
		  	.to_return(body: '{
					"response": {
						"game_count": 4,
						"games": [
								{
									"appid": 4760,
									"playtime_forever": 53
								},
								{
									"appid": 7830,
									"playtime_forever": 67
								},
								{
									"appid": 25890,
									"playtime_forever": 18580
								},
								{
									"appid": 34030,
									"playtime_forever": 11805
								}
							]
						}
					}')
		end
		
		it 'returns list of games for player' do
		  player_data = player.owned_games
		  expect(player_data.count).to eq 4
		  expect(player_data.games.first['appid']).to eq 4760 
		  expect(player_data.games.last['playtime_forever']).to eq 11805 
		end

		context 'when include_played_free_games config attribute was set to true' do

			before do
				stub_request(:get, 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001?format=json&key=12&steamid=12345&include_played_free_games=1')
					.to_return(body: '{ "response": { "game_count": 0, "games": [] } }')  
			end
		  
			it 'generates correct Steam URL' do
				player_data = player.owned_games(include_played_free_games: true)
				expect(a_request(:get, 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001?format=json&key=12&steamid=12345&include_played_free_games=1')).to have_been_made.once  
			end

		end

		context 'when include_appinfo config attribute was set to true' do
		  
		  before do
		  	stub_request(:get, 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001?format=json&key=12&steamid=12345&include_appinfo=1')
		  		.to_return(body: '{
		  			"response": {
		  				"game_count": 1,
		  				"games": [
		  						{
										"appid": 4760,
										"name": "Rome: Total War",
										"playtime_2weeks": 1,
										"playtime_forever": 53,
										"img_icon_url": "5dc68565149dc971af6428157bcb600d80690080",
										"img_logo_url": "134817933edf4f8d0665d456889c0315c416fff2",
										"has_community_visible_stats": true
									}
		  					]
		  				}
		  			}'
		  		)	 		  
		  end	

			it 'generates correct Steam URL' do
				player_data = player.owned_games(include_appinfo: true)
				expect(a_request(:get, 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001?format=json&key=12&steamid=12345&include_appinfo=1')).to have_been_made.once	  
			end

			it 'returns additional info about game' do
				player_data = player.owned_games(include_appinfo: true)
				game = player_data.games.first
				expect(game['name']).to eq 'Rome: Total War'
				expect(game['img_icon_url']).to eq '5dc68565149dc971af6428157bcb600d80690080'
				expect(game['img_logo_url']).to eq '134817933edf4f8d0665d456889c0315c416fff2'
				expect(game['playtime_2weeks']).to eq 1
				expect(game['has_community_visible_stats']).to be true  	  
			end

		end

	end

	describe '#stats_for_game' do

		context 'when game has stats' do
		  
			before do
				stub_request(:get, "http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002?format=json&appid=3&key=12&steamid=12345")  
					.to_return(body: '
						{
							"playerstats": {
								"steamID": "123",
								"gameName": "ValveTestApp8930",
								"achievements": [
									{
										"name": "ACHIEVEMENT_WIN_WASHINGTON",
										"achieved": 1
									},
									{
										"name": "ACHIEVEMENT_WIN_ELIZABETH",
										"achieved": 1
									}
								],
								"stats": [
									{
										"name": "ESTEAMSTAT_TOTAL_WINS",
										"value": 24
									},
									{
										"name": "ESTEAMSTAT_ARCHER",
										"value": 140
									}
								]
							}
						}
					')
			end
			
			it 'returns player stats for a game' do
				data = player.stats_for_game(3)
				expect(data.steam_id).to eq '123'
				expect(data.game_name).to eq 'ValveTestApp8930' 		
				expect(data.achievements.length).to eq 2		
				expect(data.stats.length).to eq 2
				expect(data.success).to be true	
			end

		end

		context 'when game does not have stats' do
		  
			before do
			  stub_request(:get, "http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002?format=json&appid=3&key=12&steamid=12345")
			  	.to_return(status: [400, 'Bad Request'], body: '{}')
			end

			it 'returns object with success attribute set to false' do
			  data = player.stats_for_game(3)
			  expect(data.success).to be false 
			end

		end
	  

	end

	describe '#achievements' do

		context 'when game has stats' do

			before do
			  stub_request(:get, "http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001?format=json&&appid=12&key=12&steamid=12345")
			  	.to_return(body: '
						{
							"playerstats": {
								"steamID": "123",
								"gameName": "Sid Meier\'s Civilization V",
								"achievements": [
									{
										"apiname": "ACHIEVEMENT_WIN_WASHINGTON",
										"achieved": 1,
										"name": "First in the Hearts of Your Countrymen",
										"description": "Beat the game on any difficulty setting as Washington."
									},
									{
										"apiname": "ACHIEVEMENT_WIN_ELIZABETH",
										"achieved": 1,
										"name": "Video et Taceo",
										"description": "Beat the game on any difficulty setting as Elizabeth."
									}
									],
								"success": true
							}
						}
			  	')
			end

			it 'returns list of player achievements for game' do
			  data = player.achievements(12)
			  expect(data.steam_id).to eq '123'
			  expect(data.game_name).to eq 'Sid Meier\'s Civilization V'
			  expect(data.achievements.size).to eq 2
			  expect(data.success).to be true 
			end
		  
		end

		context 'when game does not have stats' do
		  
			before do
			  stub_request(:get, "http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001?format=json&&appid=12&key=12&steamid=12345")
			  	.to_return(status: [400, 'Bad Request'], body: '
						{
							"playerstats": {
								"error": "Requested app has no stats",
								"success": false
							}
						}
			  	')
			end

			it 'returns object with success attribute set to false' do
			  data = player.achievements(12)
			  expect(data.success).to eq false 
			end

		end
	  

	end

end