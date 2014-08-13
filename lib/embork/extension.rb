require 'embork/sprockets/helpers'
require 'embork/borkfile'

class Embork::Extension
  def initialize(borkfile_path, bundled_assets = false, environment = nil)
    @borkfile = Embork::Borkfile.new options[:borkfile], environment
    @environment = environment || Embork.env || ENV['RACK_ENV']
    if bundled_assets
      version_file_path = File.join(@borkfile.project_root, 'build',
                                    @environment.to_s, 'current-version')
      @bundle_version = File.read(version_file_path)
      @use_bundled_assets = true
    end
  end

  def helpers
    helpers = Embork::Sprockets::Helpers
    if @use_bundled_assets
      helpers.bundle_version = @bundle_version
      helpers.use_bundled_assets = @use_bundled_assets
    end
    helpers
  end

end
