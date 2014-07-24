require 'rack'

require 'embork/environment'
require 'embork/pushstate'
require 'embork/forwarder'
require 'embork/build_versions'
require 'webrick'

class Embork::Server
  include Embork::BuildVersions

  attr_reader :backend
  attr_reader :project_root
  attr_reader :sprockets_environment
  attr_reader :app

  def initialize(borkfile, options = {})
    @borkfile = borkfile
    if !options[:bundle_version].nil?
      Embork.bundle_version = options[:bundle_version]
      setup_bundled_mode
    elsif options[:with_latest_bundle]
      Embork.bundle_version = sorted_versions(@borkfile.project_root).first
      setup_bundled_mode
    elsif options[:enable_tests]
      @testing = true
      setup_test_mode
    else
      setup_dev_mode
    end
    @port = options[:port]
    @host = options[:host]
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
      run Rack::File.new(static_directory)
    end
  end

  def setup_test_mode
    setup_dev_mode
    @sprockets_environment.prepend_path 'tests'
  end

  def set_backend
    if @borkfile.backend == :static_index
      @backend = Embork::Pushstate
    else
      Embork::Forwarder.target = @borkfile.backend
      @backend = Embork::Forwarder
    end
  end

  def run
    opts = {
      :Port => @port,
      :Host => @host
    }
    if @testing
      opts[:Logger] = WEBrick::Log.new("/dev/null")
      opts[:AccessLog] = []
    end
    Rack::Handler::WEBrick.run @app, opts
  end

end
