require "spec_helper"

RSpec.describe SteamWebApi do

	let(:base) { base = SteamWebApi::Base.new }
	let(:raw_body) { '{"response":{"someData":"hello","numbers":["1", "2", "3"],"objects":[{"a":1},{"b":2}]}}' }
	let(:response) { OpenStruct.new(status: 200, body: raw_body) }
	let(:response_not_successful) { OpenStruct.new(status: 403, body: '{}') }

	describe '#get' do

		before do
		  stub_request(:get, "http://api.steampowered.comiplayerservice/GetOwnedGames/v0001?format=json&key1=somevalue&key2=2")
		  	.to_return(status: 200)
		end
	  
		it 'returns proper url' do
			response = base.get 'IPlayerService/GetOwnedGames/v0001', key1: 'somevalue', key2: 2
			expect(response).to an_instance_of Faraday::Response
		end

	end

	describe '#parse_response' do
	  
		it 'returns parsed json' do
			base.response = OpenStruct.new(status: 200, body: '{"response":{"someData":"hello","numbers":["1", "2", "3"]}}')
		  data = base.parse_response['response']
		  expect(data['someData']).to eq 'hello' 
		  expect(data['numbers']).to eq(["1", "2", "3"])
		end

	end

	describe '.build_response' do
	  
		context 'when response is successful' do
		  
		  it 'returns correct object' do
		  	data = SteamWebApi::Base.build_response(response, 'response') { |data| { some_data: data['someData'], my_numbers: data['numbers'], objects: data['objects'] } }
		  	expect(data.success).to be true
		  	expect(data.some_data).to eq 'hello'
		  	expect(data.my_numbers).to match_array ['1','2','3']
		  	expect(data.objects).to eq([{"a" => 1}, {"b" => 2}])
		  end

		end

		context 'when response is not successful' do
		  
			it 'returns correct object' do
			  data = SteamWebApi::Base.build_response(response_not_successful, 'response') { |data| { some_data: data['someData'], my_numbers: data['numbers'], objects: data['objects'] } }
			  expect(data.success).to be false
			end

		end

	end

	describe '#build_response' do
	  
		context 'when response is successful' do
		 
			before do
			  base.response = response
			end

			it 'returns correct object' do
			  response = base.build_response('response') { |data| { some_data: data['someData'], my_numbers: data['numbers'], objects: data['objects'] } }
			  expect(response.success).to be true
			  expect(response.some_data).to eq 'hello'
			  expect(response.my_numbers).to match_array(['1','2','3'])  
			  expect(response.objects.first).to eq({"a" => 1}) 
			  expect(response.objects.last).to eq({"b" => 2}) 
			end

		end

		context 'when response is not successful' do
		  
			before do
			  base.response = response_not_successful
			end

			it 'returns correct object' do
				response = base.build_response('response') { |data| { same_data: data['someData'], my_numbers: data['numbers'], objects: data['objects'] } }
				expect(response.success).to be false
			end

		end

	end

end