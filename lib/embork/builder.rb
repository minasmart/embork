require 'pathname'
require 'fileutils'
require 'find'
require 'sprockets'

require 'embork/environment'
require 'embork/build_versions'

class Embork::Builder
  include Embork::BuildVersions

  def initialize(borkfile)
    @borkfile = borkfile
    @project_root = @borkfile.project_root
  end

  def build
    @environment = Embork::Environment.new(@borkfile)
    @sprockets_environment = @environment.sprockets_environment

    @version = Time.now.to_s.gsub(/( -|-| |:)/, '.')

    @sprockets_environment.context_class.use_bundled_assets = true
    @sprockets_environment.context_class.bundle_version = @version

    Dir.chdir @project_root do
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
        @borkfile.html.each do |file|
          dirname = File.dirname file
          extname = File.extname file
          basename = File.basename file, extname
          src_format = [ File.join(dirname, basename), @version, extname ]
          FileUtils.ln_sf(("%s-%s%s" % src_format), file)
        end
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

      # Write the current version
      Dir.chdir build_path do
        File.open('current-version', 'w') { |f| f.puts @version }
      end

      # Clean up
      FileUtils.rm manifest_path
    end

    @version
  end

  def clean
    versions = sorted_versions @project_root

    # If there are more than our threshold
    if versions.length > @borkfile.keep_old_versions

      # Grab the versions to keep
      retained_versions = versions[0...@borkfile.keep_old_versions]
      build_path = File.join(@project_root, 'build', Embork.env.to_s)

      Find.find(build_path) do |file|
        name = File.basename(file)

        # Skip if this is an unversioned file
        next unless version_name(file)

        # If any version strings that we should retain are in the file name,
        # skip to next. Otherwise, obliterate.
        if retained_versions.any?{ |version| name.include?(version) }
          next
        else
          Dir.chdir(build_path){ FileUtils.rm file }
        end
      end
    end

  end

  def clean!
    FileUtils.rm_rf File.join(@project_root, 'build', Embork.env.to_s)
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
    assets.concat @borkfile.html

    assets
  end

  def generate_versioned_name(asset_name)
    ext = File.extname asset_name
    dirname = File.dirname asset_name
    filename = File.basename asset_name, ext

    File.join dirname, ("%s-%s%s" % [ filename, @version, ext ])
  end

end
