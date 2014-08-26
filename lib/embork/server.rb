require 'rack'
require 'webrick'

require 'embork/environment'
require 'embork/pushstate'
require 'embork/forwarder'

class Embork::Server
  attr_reader :backend
  attr_reader :project_root
  attr_reader :sprockets_environment
  attr_reader :port
  attr_reader :host
  attr_reader :disable_logging
  attr_reader :app

  def initialize(borkfile, options = {})
    @borkfile = borkfile
    if !options[:bundle_version].nil?
      Embork.bundle_version = options[:bundle_version]
      setup_bundled_mode
    elsif options[:with_latest_bundle]
      Embork.bundle_version = File.read(File.join(borkfile.project_root, Embork.env, current-version))
      setup_bundled_mode
    elsif options[:enable_tests]
      setup_test_mode
    else
      setup_dev_mode
    end
    @disable_logging = options[:disable_logging]
    @port = options[:port]
    @host = options[:host]
  end

  def setup_dev_mode
    @environment = Embork::Environment.new(@borkfile)
    @sprockets_environment = @environment.sprockets_environment
    @project_root = @borkfile.project_root

    static_directory = File.join(project_root, 'static')

    @cascade_apps = [
      @sprockets_environment,
      Rack::File.new(static_directory)
    ]
    @app = build_app
  end

  def setup_bundled_mode
    @project_root = File.join @borkfile.project_root, 'build', Embork.env.to_s

    static_directory = @project_root

    @cascade_apps = [ Rack::File.new(static_directory) ]
    @app = build_app
  end

  def setup_test_mode
    setup_dev_mode
    @sprockets_environment.prepend_path 'tests'
  end

  def build_app
    if @borkfile.backend == :static_index
      backend = Embork::Pushstate
    else
      Embork::Forwarder.target = @borkfile.backend
      backend = Embork::Forwarder
    end
    cascade_apps = @cascade_apps
    Rack::Builder.new do
      use backend
      run Rack::Cascade.new(cascade_apps)
    end
  end

  def run_webrick
    opts = {
      :Port => @port,
      :Host => @host
    }
    if @disable_logging
      opts[:Logger] = WEBrick::Log.new("/dev/null")
      opts[:AccessLog] = []
    end
    Rack::Handler::WEBrick.run @app, opts
  end

end
