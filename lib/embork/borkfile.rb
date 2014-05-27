require 'embork'
require 'embork/sprockets/es6_module_transpiler'

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

    def keep_old_versions(number_to_keep = nil)
      @keep_old_versions = number_to_keep || @keep_old_versions
    end

    def es6_namespace(namespace = nil)
      @es6_namespace = namespace || @es6_namespace
    end
  end

  class DSL
    include Attributes

    def initialize(environment)
      Embork.env = @environment = environment
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
      return binding
    end

    def compile_html(files)
      files = [ files ] unless files.kind_of? Array
      @html.concat files
    end
  end

  include Attributes

  def initialize(path_to_borkfile, environment = :development)
    @path_to_borkfile = path_to_borkfile
    @environment = environment.to_sym
    file = DSL.new(environment)
    file.get_binding.eval File.read(@path_to_borkfile)
    set_options file
  end

  def set_options(file)
    # Setup paths
    default_paths = [
      'app',
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
