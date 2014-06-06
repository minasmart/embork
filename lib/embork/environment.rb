require 'embork/sprockets'
require 'sprockets'
require 'tilt'

class Embork::Environment
  include Embork::Sprockets::Frameworks

  attr_reader :sprockets_environment
  attr_reader :bundle_version
  attr_reader :use_bundled_assets

  class ErblessCache < Sprockets::Cache::FileStore
    def []=(key, value)
      # This is ugly, but it keeps ERB fresh
      if value.has_key?('pathname') && value["pathname"].match(/\.erb($|\.)/)
        value
      else
        super
      end
    end
  end

  def initialize(borkfile, options = {})
    @borkfile = borkfile

    setup_sprockets

    if !@borkfile.es6_namespace.nil?
      Embork::Sprockets::ES6ModuleTranspiler.namespace = @borkfile.es6_namespace
      Embork::Sprockets::EmberHandlebarsCompiler.namespace = @borkfile.es6_namespace
    end
  end

  def setup_sprockets
    @sprockets_environment = Sprockets::Environment.new @borkfile.project_root
    cache_path = File.join @borkfile.project_root, '.cache'
    @sprockets_environment.cache = ErblessCache.new(cache_path)

    setup_sprockets_defaults

    setup_paths
    setup_helpers
    setup_processors
    setup_engines
    setup_frameworks
    setup_compressor if @borkfile.compressor
  end

  def setup_sprockets_defaults
    @sprockets_environment.register_postprocessor 'application/javascript', Embork::Sprockets::ES6ModuleTranspiler
    @sprockets_environment.register_engine '.hbs', Embork::Sprockets::EmberHandlebarsCompiler
    @sprockets_environment.register_engine '.handlebars', Embork::Sprockets::EmberHandlebarsCompiler
    ::Tilt::CoffeeScriptTemplate.default_bare = true
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
    @sprockets_environment.context_class.class_eval do
      include Embork::Sprockets::Helpers
      extend Embork::Sprockets::Helpers::ClassMethods
    end
  end

  def setup_processors
    @borkfile.sprockets_postprocessors.each do |processor|
      @sprockets_environment.register_postprocessor processor[:mime_type], processor[:klass]
    end
    @borkfile.sprockets_preprocessors.each do |processor|
      @sprockets_environment.register_preprocessor processor[:mime_type], processor[:klass]
    end
  end

  def setup_engines
    @borkfile.sprockets_engines.each do |engine|
      @sprockets_environment.register_engine engine[:extension], engine[:klass]
    end
  end

  def setup_frameworks
    @borkfile.frameworks.each do |framework|
      method = ('load_%s_framework' % framework).to_sym
      self.send method, @sprockets_environment
    end
  end

  def setup_compressor
    if @borkfile.compressor == :closure_compiler
      @sprockets_environment.register_bundle_processor 'application/javascript',
        Embork::Sprockets::ClosureCompiler
    end
  end
end
