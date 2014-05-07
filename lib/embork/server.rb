require 'embork/environment'
require 'embork/pushstate'
require 'embork/forwarder'

require 'rack'

class Embork::Server
  attr_reader :backend
  attr_reader :project_root
  attr_reader :sprockets_environment
  attr_reader :app


  def initialize(borkfile)
    @environment = Embork::Environment.new(borkfile)
    @sprockets_environment = @environment.sprockets_environment
    @project_root = borkfile.project_root
    if borkfile.backend == :static_index
      @backend = Embork::Pushstate
    else
      Embork::Forwarder.target = borkfile.backend
      @backend = Embork::Forwarder
    end

    container = self
    static_directory = File.join(container.project_root, 'static')

    @app = Rack::Builder.new do
      use Rack::Static, :urls => [ '/images', '/fonts', ], :root => static_directory
      use container.backend

      map '/' do
        run container.sprockets_environment
      end
    end
  end

end
