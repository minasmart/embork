require "embork/version"

require "string/strip"

require "embork/borkfile"
require "embork/builder"
require "embork/environment"
require "embork/forwarder"
require "embork/generator"
require "embork/logger"
require "embork/pushstate"
require "embork/server"
require "embork/sprockets"

class Embork
  def self.env
    @env
  end

  def self.env=(environment)
    @env = environment
  end
end
