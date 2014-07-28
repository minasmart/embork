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
require "embork/phrender"
require "embork/sprockets"

class Embork
  class << self
    attr_accessor :env
    attr_accessor :bundle_version
  end
end
