# SteamWebApi

This is gem that it makes trivial to use Steam Web API. It supports all methods listed here: https://developer.valvesoftware.com/wiki/Steam_Web_API

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

This is better not to include API key as plain text in you repository. For better solution, please check [dotenv gem](https://github.com/bkeepers/dotenv).

### Player

**Get list of owned games** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29). To make it possible to make this API call, you need to have API key for your app and steam identifier of the Steam user.

```ruby
# player_steam_id - this is a Steam identifier for user
player = SteamWebApi::Player(player_steam_id)
data = player.owned_games
data.count # how many games user posses (integer)
data.games # list of user's games
data.success # boolean value indicates if request was succesful

# game datails
game = data.games.first
game['appid'] # identifier for game (integer)
game['playtime_forever'] # total playtime for game (integer)

# additional options
# 1. include_played_free_games - include free games in results
# 2. include_appinfo - include game name and logo information in the output. The default is to return appids only.
data = player.owned_games(include_played_free_games: true, include_appinfo: true)

# if include_appinfo is set to true
game = data.games.first
game['name'] # game's name
game['playtime_2weeks'] # total number of minutes played in the last 2 weeks
game['img_icon_url'] # filename of game's icon
game['img_logo_url'] # filename of game logo
game['has_community_visible_stats'] # indicates there is a stats page with achievements or other game stats available for this game
```

**Get user stats for game** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29). To make it possible to make this API call, you need to have API key for your app and steam identifier of the Steam user.

```ruby
player = SteamWebApi::Player(player_steam_id)
data = player.stats_for_game(game_id)

data.steam_id # user steam identifier
data.game_name # game name
data.achievements # list of achievements
data.stats # list of stats
data.success # boolean value indicates if request was succesful. If false, probably the game doesn't have stats and Steam returns 400 status

achievement = data.achievements.first
achievement['name'] # achievement identifier
achievement['achieved'] # integer (0 or 1)

stat = data.stats.first
stat['name']
stat['value'] # integer
```

**Get user achievements for game** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerAchievements_.28v0001.29). To make it possible to make this API call, you need to have API key for your app and steam identifier of the Steam user.

```ruby
player = SteamWebApi::Player(player_steam_id)
data = player.achievements(game_id)

data.steam_id # user steam identifier
data.game_name # game name
data.achievements # list of achievements
data.success # boolean value indicates if request was succesful. If false, probably the game doesn't have stats and Steam returns 400 status

achievement = data.achievements.first
achievement['apiname'] # achievement name
achievement['achieved'] # integer (0 or 1)

# additional options
# 1. l - Language. If specified, it will return language data (name, description) for the requested language.
data = player.achievements(game_id, l: 'en')
achievement = data.achievements.first
achievement['name'] # achievement name
achievement['description'] # achievement description
```




## Contributing

1. Fork it ( https://github.com/[my-github-username]/steam_web_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
