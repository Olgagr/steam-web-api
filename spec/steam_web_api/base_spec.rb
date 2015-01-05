require "spec_helper"

RSpec.describe SteamWebApi do

	describe '#build' do
	  
		it 'returns proper url' do
			base = SteamWebApi::Base.new
			url = base.build 'IPlayerService/GetOwnedGames/v0001', key1: 'somevalue', key2: 2
			expect(url).to eq 'http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001?format=json&key1=somevalue&key2=2'   	
		end

	end

end