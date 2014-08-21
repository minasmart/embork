require 'embork'
require 'qunit/runner'
require 'thor'

class Embork::CLI < Thor
  class_option :borkfile, :type => :string, :default => "./Borkfile",
    :desc => "Path to the embork config file."

  desc "create PACKAGE_NAME", %{generate an Embork Ember application called "PACKAGE_NAME"}
  option :use_ember_data, :type => :boolean, :default => false
  option :directory, :type => :string, :default => nil
  def create(package_name)
    puts %{Creating embork app in "%s"} % package_name
    Embork::Generator.new(package_name, options).generate
  end

  desc "server [ENVIRONMENT]", %{run the development or production server}
  option :port, :type => :numeric, :default => 9292
  option :host, :type => :string, :default => 'localhost'
  option :bundle_version, :type => :string, :default => nil
  option :with_latest_bundle, :type => :boolean, :default => false
  option :enable_tests, :type => :boolean, :default => false
  def server(environment = :development)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    Embork::Server.new(borkfile, options).run_webrick
  end

  desc "phrender [ENVIRONMENT]", %{run phrender the prerenderer}
  option :port, :type => :numeric, :default => 9292
  option :host, :type => :string, :default => 'localhost'
  option :bundle_version, :type => :string, :default => nil
  option :with_latest_bundle, :type => :boolean, :default => false
  def phrender(environment = :development)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    Embork::Phrender.new(borkfile, options).run_webrick
  end

  desc "test [ENVIRONMENT]", %{run the qunit test suite}
  def test(environment = :development)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    min = 52000
    max = 65000
    port = (Random.rand * (max - min) + min).to_i
    host = 'localhost'

    server_options = {
      :host => host,
      :port => port,
      :enable_tests => true,
      :disable_logging => true
    }

    server = Embork::Server.new(borkfile, server_options)

    server_thread = Thread.new{ server.run_webrick }

    test_url = "http://%s:%s/tests.html" % [ host, port ]
    Qunit::Runner.new(test_url).run(10000)
    server_thread.kill
  end

  desc "build [ENVIRONMENT]", %{build the project in the 'build' directory}
  option :keep_all_old_versions, :type => :boolean, :default => false,
    :desc => %{By default, older versions of the project are removed, only keeping the last few versions. This flag keeps all old versions.}
  def build(environment = :production)
    borkfile = Embork::Borkfile.new options[:borkfile], environment
    builder = Embork::Builder.new(borkfile)
    builder.build
    if !options[:keep_all_old_versions]
      builder.clean
    end
  end

  desc "clean", %{Remove all files under the build directory}
  def clean
    borkfile = Embork::Borkfile.new options[:borkfile]
    FileUtils.rm_rf File.expand_path('build', borkfile.project_root)
  end

  desc "clean-cache", %{Blow away the sprockets cache}
  def clean_cache
    borkfile = Embork::Borkfile.new options[:borkfile]
    FileUtils.rm_rf File.expand_path('.cache', borkfile.project_root)
  end

  desc "hint", %{run jshint on the app and tests}
  def hint
    borkfile = Embork::Borkfile.new options[:borkfile]
    Dir.chdir borkfile.project_root do
      system('PATH=$(npm bin):$PATH jshint app tests')
    end
  end

  desc "deps", "Install bower and node dependencies"
  def deps
    if !system('which node 2>&1 > /dev/null')
      puts "Please install node and npm before continuing."
      exit 1
    elsif !system('which npm 2>&1 > /dev/null')
      puts "Please install npm before continuing."
      exit 1
    end
    borkfile = Embork::Borkfile.new options[:borkfile]
    Dir.chdir borkfile.project_root do
      system('npm install')
      system('PATH=$(npm bin):$PATH bower install')
    end
  end

end
