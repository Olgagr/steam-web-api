require "spec_helper"

RSpec.describe SteamWebApi::Player do

	let(:player) { SteamWebApi::Player.new('76561198046174695') }
	let(:player_2) { SteamWebApi::Player.new('76561197960435530') }
	let(:player_non_existing) { SteamWebApi::Player.new('aaa') }

	before do
	  SteamWebApi.configure do |config|
	  	config.api_key = ENV['STEAM_WEB_API_KEY']
	  end
	end

	describe '#owned_games' do
		
		it 'returns list of games for player' do
			VCR.use_cassette('player_owned_games') do
			  player_data = player.owned_games
			  expect(player_data.count).to eq 45
			  expect(player_data.games.first['appid']).to eq 4760 
			  expect(player_data.games.last['playtime_forever']).to eq 0 
			end
		end

		context 'when include_appinfo config attribute was set to true' do

			it 'returns additional info about game' do
				VCR.use_cassette('player_owned_games_appinfo') do
					player_data = player.owned_games(include_appinfo: true)
					game = player_data.games[3]
					expect(game['name']).to eq 'Napoleon: Total War'
					expect(game['img_icon_url']).to eq 'e6263fa77b39b3b83db00d089aed8dc0aac11b20'
					expect(game['img_logo_url']).to eq 'eca670df2bb35587996bfb4da6a45a8985ace139'
					expect(game['has_community_visible_stats']).to be true
				end  	  
			end

		end

	end

	describe '#stats_for_game' do

		context 'when game has stats' do
			
			it 'returns player stats for a game' do
				VCR.use_cassette('stats_for_game') do
					data = player.stats_for_game(8930)
					expect(data.steam_id).to eq '76561198046174695'
					expect(data.game_name).to eq 'ValveTestApp8930' 		
					expect(data.achievements.length).to eq 151	
					expect(data.stats.length).to eq 134
					expect(data.success).to be true	
				end
			end

		end

		context 'when game does not have stats' do

			it 'returns object with success attribute set to false' do
				VCR.use_cassette('stats_for_game_empty') do
			  	data = player.stats_for_game(4760)
			  	expect(data.success).to be false 
				end
			end

		end
	  

	end

	describe '#achievements' do

		context 'when game has stats' do

			it 'returns list of player achievements for game' do
				VCR.use_cassette('player_achievements') do
				  data = player.achievements(232050)
				  expect(data.steam_id).to eq '76561198046174695'
				  expect(data.game_name).to eq 'Eador. Masters of the Broken World'
				  expect(data.achievements.size).to eq 55
				  expect(data.success).to be true 
				end
			end
		  
		end

		context 'when game does not have stats' do

			it 'returns object with success attribute set to false' do
				VCR.use_cassette('player_achievements_empty') do
			  	data = player.achievements(4760)
			  	expect(data.success).to eq false 
				end
			end

		end
	  

	end

	describe '.summary' do
	  
		context 'when response is successful' do
		  
			it 'returns profile information for players' do
				VCR.use_cassette('player_summary') do
					data = SteamWebApi::Player.summary(player.steam_id, player_2.steam_id)
					first_player = data.players.first
					second_player = data.players[1]
					expect(first_player['steamid']).to eq '76561198046174695'
					expect(first_player['personaname']).to eq 'gravin79'
					expect(first_player['realname']).to eq 'GTomasz'     
					expect(second_player['steamid']).to eq '76561197960435530'
					expect(second_player['realname']).to eq 'Robin Walker'
					expect(second_player['personaname']).to eq 'Robin'
				end		  
			end

		end

		context 'when response is not successful' do

			before do
			  SteamWebApi.configure do |config|
			  	config.api_key = 'invalid'
			  end
			end
		  
			it 'returns object with attribute success equals false and empty list' do
			  VCR.use_cassette('player_summary_error') do
			  	data = SteamWebApi::Player.summary(player.steam_id, player_2.steam_id)
			  	expect(data.players.size).to eq 0
			  	expect(data.success).to be false
			  end
			end

		end

	end

	describe '#summary' do

		context 'when response is successful' do
		  
			it 'returns profile information for single player' do
				VCR.use_cassette('player_single_summary') do
					data = player.summary
					expect(data.profile['steamid']).to eq '76561198046174695'
					expect(data.profile['personaname']).to eq 'gravin79'
					expect(data.profile['realname']).to eq 'GTomasz'
				end  
			end

		end

		context 'when response is not successful' do
		  
			before do
			  SteamWebApi.configure do |config|
			  	config.api_key = 'invalid'
			  end
			end

			it 'returns object with empty profile hash and attribute success equals false' do
			  VCR.use_cassette('player_single_summary_error') do
			  	data = player.summary
			  	expect(data.success).to be false
			  	expect(data.profile).to be {}  
			  end
			end

		end

	end

	describe '#friends' do

		context 'when response is successful' do
		  
			it 'returns list of friends' do
				VCR.use_cassette('player_friends') do
					data = player.friends
					expect(data.success).to be true
					expect(data.friends).not_to be_empty

					friend = data.friends.first
					expect(friend['steamid']).to eq '76561197968589933'
					expect(friend['relationship']).to eq 'friend'
					expect(friend['friend_since']).to eq 1397319937     
				end
			end

		end

		context 'when response is not successful' do
		  
			it 'returns empty list of friends and attribute success equals false' do
			  VCR.use_cassette('player_friends_error') do
			  	data = player_non_existing.friends
			  	expect(data.success).to be false
			  	expect(data.friends).to be_empty  
			  end
			end

		end

	end

end