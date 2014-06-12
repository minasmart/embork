require 'embork'
require 'embork/sprockets'
require 'embork/logger'

class Embork::Borkfile
  module Attributes
    attr_reader :asset_paths
    attr_reader :helpers
    attr_reader :project_root
    attr_reader :sprockets_postprocessors
    attr_reader :sprockets_preprocessors
    attr_reader :sprockets_engines
    attr_reader :backend
    attr_reader :html
    attr_reader :frameworks
    attr_reader :compressor
    attr_reader :es6_transform

    def keep_old_versions(number_to_keep = nil)
      @keep_old_versions = number_to_keep || @keep_old_versions
    end

    def es6_namespace(namespace = nil)
      @es6_namespace = namespace || @es6_namespace
    end
  end

  class DSL
    include Attributes

    SUPPORTED_FRAMEWORKS = %w(bootstrap compass)
    SUPPORTED_COMPRESSORS = %w(closure_compiler uglifier)

    def initialize(environment, logger)
      Embork.env = @environment = environment.to_sym
      @asset_paths = []
      @helpers = []
      @sprockets_postprocessors = []
      @sprockets_preprocessors = []
      @sprockets_engines = []
      @project_root = nil
      @html = []
      @backend = :static_index
      @keep_old_versions = 5
      @es6_namespace = nil
      @frameworks = []
      @logger = logger
      @compressor = nil
      @es6_transform = nil
    end

    def use_framework(framework)
      framework = framework.to_s
      if SUPPORTED_FRAMEWORKS.include? framework
        @frameworks.push framework
      else
        @logger.critical 'Framework "%s" is not currently supported by embork.' % framework
        @logger.unknown ''
        exit 1
      end
    end

    def register_postprocessor(mime_type, klass)
      @sprockets_postprocessors.push({ :mime_type => mime_type, :klass => klass })
    end

    def register_preprocessor(mime_type, klass)
      @sprockets_preprocessors.push({ :mime_type => mime_type, :klass => klass })
    end

    def register_engine(extension, klass)
      @sprockets_engines.push({ :extension => extension, :klass => klass })
    end

    def append_asset_path(path)
      @asset_paths.push path
    end

    def add_sprockets_helpers(&block)
      helpers.push block
    end

    def set_project_root(path)
      @project_root = path
    end

    def set_backend(app)
      @backend = app
    end

    def configure(environment, &block)
      if environment == @environment
        self.instance_exec &block
      end
    end

    def get_binding
      binding
    end

    def compile_html(files)
      files = [ files ] unless files.kind_of? Array
      @html.concat files
    end

    def compress_with(compressor)
      if SUPPORTED_COMPRESSORS.include? compressor.to_s
        @compressor = compressor
      else
        @logger.critical 'Compressor "%s" is not currently supported by embork.' % compressor.to_s
        @logger.unknown ''
        exit 1
      end
    end

    def transform_es6_module_names(transform_proc)
      if transform_proc.respond_to?(:call) || transform_proc.nil?
        @es6_transform = transform_proc
      else
        @logger.critical 'ES6 Module transform must respond to #call'
        exit 1
      end
    end

  end

  include Attributes

  def initialize(path_to_borkfile, environment = :development)
    @logger = Embork::Logger.new(STDOUT, :simple)
    @path_to_borkfile = path_to_borkfile
    @environment = environment.to_sym
    check_borkfile
    file = DSL.new(environment, @logger)
    file.get_binding.eval File.read(@path_to_borkfile)
    set_options file
  end

  protected

  def check_borkfile
    unless File.exists? @path_to_borkfile
      @logger.error 'No Borkfile found at %s.' % @path_to_borkfile
      exit 1
    end
  end

  def set_options(file)
    # Setup paths
    default_paths = [
      'app',
      'app/styles',
      'config/%s' % [ @environment.to_s ],
      'components'
    ]
    @asset_paths = default_paths.concat file.asset_paths

    # Setup root
    if file.project_root
      if file.project_root[0] == '/'
        @project_root = file.project_root
      else
        @project_root = File.expand_path "../#{file.project_root}", @path_to_borkfile
      end
    else
      @project_root = File.expand_path '..', @path_to_borkfile
    end

    # Copy everything else
    (Attributes.instance_methods - [ :asset_paths, :project_root ]).each do |attr|
      self.instance_variable_set("@#{attr}".to_sym, file.send(attr))
    end
  end
end
