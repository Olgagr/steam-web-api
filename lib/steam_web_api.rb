require "steam_web_api/version"
require "steam_web_api/configuration"
require "steam_web_api/base"
require "steam_web_api/player"

begin
	require "byebug"
rescue LoadError
end

module SteamWebApi
  
	class << self

		attr_writer :config

		def config
			@configuration ||= SteamWebApi::Configuration.new
		end

		def configure
			yield config
		end

	end

end
