require "spec_helper"

RSpec.describe SteamWebApi do

	describe '#get' do

		before do
		  stub_request(:get, "http://api.steampowered.comiplayerservice/GetOwnedGames/v0001?format=json&key1=somevalue&key2=2")
		  	.to_return(status: 200)
		end
	  
		it 'returns proper url' do
			base = SteamWebApi::Base.new
			response = base.get 'IPlayerService/GetOwnedGames/v0001', key1: 'somevalue', key2: 2
			expect(response).to an_instance_of Faraday::Response
		end

	end

end