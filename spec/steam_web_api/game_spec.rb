require "spec_helper"

RSpec.describe SteamWebApi::Game do

	let(:game) { SteamWebApi::Game.new(8930) }
	let(:non_existing_game) { SteamWebApi::Game.new('non-existing') }

	before do
	  SteamWebApi.configure do |config|
	  	config.api_key = ENV['STEAM_WEB_API_KEY']
	  end
	end
  
	describe '.all' do

		before do
			# this is a huge list, so just stub and not use vcr
		  stub_request(:get, 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
		  	.to_return(body: '
		  		{
		  			"applist": {
		  				"apps": [
		  					{
		  						"appid": 5,
		  						"name": "Dedicated Server"
		  					},
		  					{
		  						"appid": 7,
		  						"name": "Steam Client"
		  					},
		  					{
		  						"appid": 8,
		  						"name": "winui2"
		  					}
		  				]
		  			}
		  		}
		  	')
		end
	  
		it 'return lists of all games on Steam' do
			data = SteamWebApi::Game.all
			expect(data.success).to be true
			expect(data.games.size).to eq 3
		end

	end

	describe '#schema' do
	  
		it 'returns game schema' do
		  VCR.use_cassette('game_schema') do
		  	schema = game.schema
		  	expect(schema.name).to eq 'ValveTestApp8930'
		  	expect(schema.version).to eq '108'
		  	expect(schema.achievements.first).to eq(
		  			{ 
		  				"name" => "ACHIEVEMENT_WIN_WASHINGTON",
							"defaultvalue" => 0,
							"displayName" => "First in the Hearts of Your Countrymen",
							"hidden" => 0,
							"description" => "Beat the game on any difficulty setting as Washington.",
							"icon" => "http://cdn.akamai.steamstatic.com/steamcommunity/public/images/apps/8930/4cf17a59d70b2decfd4369de8a7429e7b00f5ab8.jpg",
							"icongray" => "http://cdn.akamai.steamstatic.com/steamcommunity/public/images/apps/8930/2ce109f9be6cb3193a385444b9b0b0ffcc7b2219.jpg"
		  			}
		  		)
		  	expect(schema.stats.first).to eq(
		  		{
		  			"name" => "ESTEAMSTAT_TOTAL_WINS",
						"defaultvalue" => 0,
						"displayName" => "Total Games Won."
		  		}
		  	) 
		  	expect(schema.success).to be true
		  end
		end

	end

	describe '#achievement_percentages' do

		context 'when the response is successful' do
		 	
			it 'returns list of achievements with global percentage stats' do
			  VCR.use_cassette('game_achievement_percentages') do
			  	data = game.achievement_percentages
			  	expect(data.achievements.first['name']).to eq 'ACHIEVEMENT_ANCIENT_RUIN'
			  	expect(data.achievements.first['percent']).to eq 76.74992370605469
			  	expect(data.success).to be true 
			  end
			end

		end
	  
	  context 'when the response is not successful' do
	    
	  	it 'returns object with attribute success equals false and empty list' do
	  	  VCR.use_cassette('game_achievement_percentages_error') do
	  	  	data = non_existing_game.achievement_percentages
	  	  	expect(data.success).to be false
	  	  end
	  	end

	  end
		

	end

	describe '#news' do
	  
		context 'when response is successful' do
		  
			it 'returns list of news' do
			  VCR.use_cassette('game_news_success') do
			  	data = game.news(count: 4)
			  	expect(data.news_items.size).to eq 4
			  	expect(data.app_id).to eq 8930
			  	expect(data.success).to be true   
			  end
			end

		end

		context 'when response is not successful' do
		  
			it 'returns object with attribute success equals false and empty list' do
			  VCR.use_cassette('game_news_error') do
			  	data = non_existing_game.news
			  	expect(data.success).to be false
			  end
			end

		end

	end

end