# SteamWebApi

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'steam_web_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install steam_web_api

## Usage

### Configuration

Some Steam Web API methods return publicly accessible data and do not require authorization when called. Other methods may require clients to register for an API key and pass that in using the key parameter. There are also methods that return sensitive data or perform a protected action and require special access permissions. To retrieve API key for your application, you'll need log in to your Steam account and fill [this form](http://steamcommunity.com/dev/apikey)

When you have your API key, you can configure the gem:

```ruby
# for Rails, you can put this code in initializer: config/initializers/steam_web_api.rb
SteamWebApi.configure do |config|
	config.steam_web_api_key = 'your api key'
end
```

This is better to not include API key as plain text in you repository. For better solution, please check (dotenv gem)[https://github.com/bkeepers/dotenv]

## Contributing

1. Fork it ( https://github.com/[my-github-username]/steam_web_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
