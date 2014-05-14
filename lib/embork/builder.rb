require 'pathname'
require 'fileutils'
require 'sprockets'

require 'embork/environment'

class Embork::Builder
  def initialize(borkfile)
    @borkfile = borkfile
    @project_root = @borkfile.project_root
  end

  def build
    @environment = Embork::Environment.new(@borkfile)
    @sprockets_environment = @environment.sprockets_environment
    @version = Time.now.to_s.gsub(/( -|-| |:)/, '.')
    @config_directory = File.join @borkfile.project_root, 'config', Embork.env.to_s
    @manifest_path = File.join @borkfile.project_root, 'build', 'manifest.json'

    c = Pathname.new @config_directory

    @assets = []
    Dir.glob(File.join(@config_directory, '**/*')) do |file|
      if !File.directory? file
        path = Pathname.new(file)
        @assets.push path.relative_path_from(c).to_s
      end
    end

    @assets.push 'index.html' if @borkfile.backend == :static_index

    manifest = Sprockets::Manifest.new(@sprockets_environment, @manifest_path)
    manifest.compile(@assets)

    @assets.each do |asset|
      digested_name = manifest.assets[asset]
      gzipped_name = "%s%s" % [ digested_name, '.gz' ]

      ext = File.extname asset
      dirname = File.dirname asset
      filename = File.basename asset, ext
      versioned_name = File.join dirname, ("%s-%s%s" % [ filename, @version, ext ])

      Dir.chdir File.dirname(@manifest_path) do
        File.rename digested_name, versioned_name
        FileUtils.rm gzipped_name
      end
    end

    if @borkfile.backend == :static_index
      Dir.chdir File.dirname(@manifest_path) do
        FileUtils.ln_sf "index-#{@version}.html", 'index.html'
      end
    end

    @version
  end

  def clean(bundle_version)
  end

  def clean!
  end
end
