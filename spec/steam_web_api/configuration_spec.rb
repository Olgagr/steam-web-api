require "spec_helper"

RSpec.describe SteamWebApi::Configuration do

	describe '#api_key' do

		let(:config) { SteamWebApi::Configuration.new }
	  
		it 'sets Steam Web API key' do
		  config.api_key = 'Some key'
		  expect(config.api_key).to eq 'Some key' 
		end

	end

end