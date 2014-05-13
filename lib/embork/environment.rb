require 'embork/sprockets'
require 'sprockets'

class Embork::Environment
  attr_reader :sprockets_environment
  attr_reader :bundle_version
  attr_reader :use_bundled_assets

  def initialize(borkfile, options = {})
    @borkfile = borkfile

    setup_sprockets
  end

  def setup_sprockets
    @sprockets_environment = Sprockets::Environment.new @borkfile.project_root
    cache_path = File.join @borkfile.project_root, '.cache'
    @sprockets_environment.cache = Sprockets::Cache::FileStore.new(cache_path)

    setup_sprockets_defaults

    setup_paths
    setup_helpers
    setup_postprocessors
    setup_engines
  end

  def setup_sprockets_defaults
    @sprockets_environment.register_engine '.es6', Embork::Sprockets::ES6ModuleTranspiler
    @sprockets_environment.register_engine '.hbs', Embork::Sprockets::EmberHandlebarsCompiler
    @sprockets_environment.register_engine '.handlebars', Embork::Sprockets::EmberHandlebarsCompiler
  end

  def setup_paths
    @borkfile.asset_paths.each do |path|
      @sprockets_environment.append_path path
    end
  end

  def setup_helpers
    @borkfile.helpers.each do |helper_proc|
      Embork::Sprockets::Helpers.class_eval &helper_proc
    end
    @sprockets_environment.context_class.class_eval { include Embork::Sprockets::Helpers }
  end

  def setup_postprocessors
    @borkfile.sprockets_postprocessors.each do |processor|
      @sprockets_environment.register_postprocessor processor[:mime_type], processor[:klass]
    end
  end

  def setup_engines
    @borkfile.sprockets_engines.each do |engine|
      @sprockets_environment.register_engine engine[:extension], engine[:klass]
    end
  end

end
