require 'sprockets'

class Embork::Environment
  attr_reader :sprockets_environment

  def initialize(borkfile)
    @borkfile = borkfile
    @sprockets_environment = Sprockets::Environment.new borkfile.project_root
    cache_path = File.join @borkfile.project_root, '.cache'
    @sprockets_environment.cache = Sprockets::Cache::FileStore.new(cache_path)

    setup_paths
    setup_helpers
    setup_postprocessors
    setup_engines
  end

  def setup_paths
    @borkfile.asset_paths.each do |path|
      @sprockets_environment.append_path path
    end
  end

  def setup_helpers
    @borkfile.helpers.each do |helper_proc|
      @sprockets_environment.context_class.class_eval &helper_proc
    end
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
