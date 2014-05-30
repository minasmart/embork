require 'embork/environment'
require 'embork/pushstate'
require 'embork/forwarder'

require 'rack'

class Embork::Server
  attr_reader :backend
  attr_reader :project_root
  attr_reader :sprockets_environment
  attr_reader :app


  def initialize(borkfile, options = {})
    @borkfile = borkfile
    if options.has_key? :bundle_version
      @bundle_version = options[:bundle_version]
      setup_bundled_mode
    else
      setup_dev_mode
    end
  end

  def setup_dev_mode
    @environment = Embork::Environment.new(@borkfile)
    @sprockets_environment = @environment.sprockets_environment
    @project_root = @borkfile.project_root

    set_backend

    container = self
    static_directory = File.join(container.project_root, 'static')

    @app = Rack::Builder.new do
      use container.backend
      use Rack::Static, :urls => [ '/images', '/fonts', ], :root => static_directory

      map '/' do
        run container.sprockets_environment
      end
    end
  end

  def setup_bundled_mode
    @project_root = File.join @borkfile.project_root, 'build', Embork.env.to_s

    set_backend

    static_directory = @project_root
    container = self

    @app = Rack::Builder.new do
      use container.backend
      use Rack::Static, :urls => [ '/' ], :root => static_directory
      # Should never reach here. It just need s an app to run
      run lambda { |env| [ 200, { 'Content-Type'  => 'text/html', }, '' ] }
    end
  end

  def set_backend
    if @borkfile.backend == :static_index
      @backend = Embork::Pushstate
    else
      Embork::Forwarder.target = @borkfile.backend
      @backend = Embork::Forwarder
    end
  end

end
