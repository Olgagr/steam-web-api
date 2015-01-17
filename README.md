# SteamWebApi

This is gem that makes trivial to use Steam Web API. It supports all methods listed here: https://developer.valvesoftware.com/wiki/Steam_Web_API

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

**Get list of owned games** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29). To make this API call, you need to have API key for your app and steam identifier of the Steam user.

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

**Get user stats for game** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29). To make this API call, you need to have API key for your app and steam identifier of the Steam user.

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

**Get user achievements for game** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerAchievements_.28v0001.29). To make this API call, you need to have API key for your app and steam identifier of the Steam user.

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

**Get accounts summaries for list of players** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29). To make this API call, you need to have API key for your app and steam identifier of the Steam user.

```ruby
data = SteamWebApi::Player.summary(player.steam_id, player_2.steam_id)
data.players # list of account summeries
data.success # boolean value indicates if request was succesful

first_player = data.players.first
first_player['steamid']
first_player['communityvisibilitystate']
first_player['profilestate']
first_player['personaname']
first_player['lastlogoff']
first_player['profileurl']
first_player['avatar']
first_player['avatarmedium']
first_player['avatarfull']
first_player['personastate']
first_player['realname']
first_player['primaryclanid']
first_player['timecreated']
first_player['personastateflags']
first_player['gameextrainfo']
first_player['gameid']
first_player['loccountrycode']
first_player['locstatecode']
first_player['loccityid']
```

**Get account summary for single player** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29). This is just more convinient method to get account summary if you already have player instance. To make this API call, you need to have API key for your app and steam identifier of the Steam user.

```ruby
player = SteamWebApi::Player.new(steam_id)
data = player.summary
data.profile # account summery
data.success # boolean value indicates if request was succesful

data.profile['steamid']
data.profile['communityvisibilitystate']
data.profile['profilestate']
data.profile['personaname']
data.profile['lastlogoff']
data.profile['profileurl']
data.profile['avatar']
data.profile['avatarmedium']
data.profile['avatarfull']
data.profile['personastate']
data.profile['realname']
data.profile['primaryclanid']
data.profile['timecreated']
data.profile['personastateflags']
data.profile['gameextrainfo']
data.profile['gameid']
data.profile['loccountrycode']
data.profile['locstatecode']
data.profile['loccityid']
```

### Game

**Get list of all games** (this end-point is not described in official documentation)

```ruby
games = SteamWebApi::Game.all
```

**Get game schema** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetSchemaForGame_.28v2.29). To make this API call, you need to have API key for your app.

```ruby
game = SteamWebApi::Game(game_id)
schema = game.schema

schema.name # game name 
schema.version # game version
schema.achievements # lists of achievements
schema.stats # list of stats
schema.success # boolean value indicates if request was succesful

achievement = schema.achievements.first
achievement['name']
achievement['defaultvalue']
achievement['displayName']
achievement['hidden'] # integer
achievement['description']
achievement['icon']
achievement['icongray']

stats = schema.stats.first
stats['name']
stats['defaultvalue']
stats['displayName']
```

**Get list of global game achievements in percentage** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetGlobalAchievementPercentagesForApp_.28v0002.29)

```ruby
game = SteamWebApi::Game(game_id)
data = game.achievement_percentages

data.achievements # list of achievements
data.success # boolean value indicates if request was succesful

achievement = data.achievements.first
achievement['name']
achievement['percent']
```

**Get list of news** (https://developer.valvesoftware.com/wiki/Steam_Web_API#GetNewsForApp_.28v0002.29)

```ruby
game = SteamWebApi::Game(game_id)
news = game.news

news.app_id # game id
news.news_items # news list
news.success # boolean value indicates if request was succesful

first_news = news.news_items.first
first_news['gid'] # string
first_news['title']
first_news['url']
first_news['is_external_url']
first_news['author']
first_news['contents']
first_news['feedlabel']
first_news['date']
first_news['feedname']

# additional options
# 1. count - default 3, how many news should be retured
# 2. max_length - default 300, how many characters news content should contain
data = game.news(count: 10, max_length: 1000)
```



## Contributing

1. Fork it ( https://github.com/[my-github-username]/steam_web_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
