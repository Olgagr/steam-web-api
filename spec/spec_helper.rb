require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require "dotenv"
Dotenv.load
require "steam_web_api"
require "webmock/rspec"
require "vcr"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr'
    c.filter_sensitive_data("<API_KEY>") { ENV["STEAM_WEB_API_KEY"] }
    c.hook_into :webmock
  end
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
 
  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

end
