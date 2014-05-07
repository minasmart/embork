require "embork/version"

require "embork/borkfile"
require "embork/environment"
require "embork/server"

class Embork
  def self.env
    @env
  end

  def self.env=(environment)
    @env = environment
  end
end
