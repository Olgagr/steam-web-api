require "spec_helper"

RSpec.describe SteamWebApi do

	describe '.configure' do
	  
		it 'sets api key for application' do
		  SteamWebApi.configure do |config|
		  	config.api_key = 'some key'
		  end

		  expect(SteamWebApi.config.api_key).to eq 'some key'
		end

	end


end