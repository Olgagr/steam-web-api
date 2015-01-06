require "spec_helper"

RSpec.describe SteamWebApi::Game do
  
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
		  expect(SteamWebApi::Game.all.size).to eq 3
		end

	end

end