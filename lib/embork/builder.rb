require 'pathname'
require 'fileutils'
require 'find'
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

    @sprockets_environment.context_class.use_bundled_assets = true
    @sprockets_environment.context_class.bundled_version = @version

    Dir.chdir @borkfile.project_root do
      config_path = File.join 'config', Embork.env.to_s
      build_path = File.join 'build', Embork.env.to_s

      asset_list = generate_asset_list config_path

      manifest_path = File.join build_path, 'manifest.json'
      manifest = Sprockets::Manifest.new(@sprockets_environment, manifest_path)
      manifest.compile(asset_list)

      # version assets
      asset_list.each do |asset|
        digested_name = manifest.assets[asset]
        gzipped_name = "%s%s" % [ digested_name, '.gz' ]
        versioned_name = generate_versioned_name(asset)

        # Do the actual renaming and removing of the gzipped file.
        # nginx handles gzipping just fine
        Dir.chdir build_path do
          File.rename digested_name, versioned_name
          FileUtils.rm gzipped_name
        end
      end

      # Link the index file since, chances are, you don't want to reconfigure
      # your index file every time you deploy.
      Dir.chdir build_path do
        FileUtils.ln_sf "index-#{@version}.html", 'index.html'
      end if @borkfile.backend == :static_index

      static_path = 'static'
      static_pathname = Pathname.new static_path
      static_directories = []
      static_files = []
      Find.find(static_path) do |file|
        relative_name = Pathname.new(file).relative_path_from(static_pathname)
        if FileTest.directory? file
          static_directories.push relative_name
        else
          static_files.push relative_name
        end
      end

      static_directories.each do |dir|
        Dir.chdir(build_path) { FileUtils.mkdir_p dir }
      end

      static_files.each do |file|
        src = File.join static_path, file
        dest = File.join build_path, file

        FileUtils.cp src, dest
      end

      # Clean up
      FileUtils.rm manifest_path
    end

    @version
  end

  def clean
    FileUtils.rm_rf File.join(@borkfile.project_root, 'build', Embork.env.to_s)
  end

  protected

  def generate_asset_list(config_path)
    config_pathname = Pathname.new config_path

    assets = []

    # Add configged assets
    Find.find(config_path) do |file|
      if FileTest.directory? file
        next
      else
        assets.push Pathname.new(file).relative_path_from(config_pathname).to_s
      end
    end

    # Optionally add an index. This should probably actually rely on a config
    # paramater in the borkfile listing out the html files to build.
    assets.push 'index.html' if @borkfile.backend == :static_index

    assets
  end

  def generate_versioned_name(asset_name)
    ext = File.extname asset_name
    dirname = File.dirname asset_name
    filename = File.basename asset_name, ext

    File.join dirname, ("%s-%s%s" % [ filename, @version, ext ])
  end

end
