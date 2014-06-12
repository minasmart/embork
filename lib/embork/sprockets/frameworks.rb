module Embork::Sprockets::Frameworks
  def load_compass_framework(sprockets_environment)
    begin
      require 'compass'
      sprockets_environment.append_path Compass::Frameworks['compass'].stylesheets_directory
      Compass.configuration.images_path = File.join sprockets_environment.root, 'static'
    rescue LoadError => e
      (@logger ||= Embork::Logger.new(STDOUT, :simple)).error 'Compass gem is not installed.'
      @logger.info %{Add `gem 'compass'` to your Gemfile and run `bundle` to install it.}
      exit 1
    end
  end

  def load_bootstrap_framework(sprockets_environment)
    base = nil
    begin
      require('compass')
      require('bootstrap-sass')
      base = File.join Compass::Frameworks['bootstrap'].path, 'vendor/assets'
    rescue LoadError => e
      begin
        require('bootstrap-sass')
        base = File.join(Gem::Specification.find_by_name('bootstrap-sass').gem_dir, 'vendor/assets')
      rescue LoadError => e
        (@logger ||= Embork::Logger.new(STDOUT, :simple)).error 'Compass gem is not installed.'
        @logger.info %{Add `gem 'bootstrap-sass'` to your Gemfile and run `bundle` to install it.}
        exit 1
      end
    end

    %w(stylesheets javascripts fonts).each do |type|
      sprockets_environment.append_path File.join(base, type)
    end
  end
end
