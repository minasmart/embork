require 'spec_helper'

require 'embork/borkfile'
require 'embork/environment'
require 'embork/builder'

require 'pathname'

describe 'Embork::Builder' do
  let(:root_path) { File.expand_path '../builder', __FILE__ }
  let(:borkfile) { Embork::Borkfile.new File.join(root_path, 'Borkfile'), :production }
  let(:builder) { Embork::Builder.new borkfile }
  let(:build_directory) { File.join(root_path, 'build', 'production') }
  let(:expected_files) do
    [
      'application-%s.css',
      'application-%s.js',
      'deeply/nested/asset-%s.js',
      'images/image.png',
      'index-%s.html',
      'index.html',
      'current-version'
    ]
  end

  after(:each) { FileUtils.rm_rf File.join(root_path, '.cache') }
  after(:all) do
    Embork::Sprockets::ES6ModuleTranspiler.namespace = nil
    Embork::Sprockets::ES6ModuleTranspiler.transform = nil
  end

  let(:built_files) do
    [].tap do |files|
      Dir.glob(File.join(build_directory, '**/*')) do |file|
        if !File.directory? file
          path = Pathname.new(file)
          files.push path.relative_path_from(Pathname.new build_directory).to_s
        end
      end
    end
  end

  before(:each) { @asset_bundle_version = builder.build }
  after(:each) { builder.clean! }

  it 'builds assets' do
    expect(File.exists? build_directory).to be true

    expect(built_files).to match_array(expected_files.map{ |f| f % [ @asset_bundle_version ] })
  end

  context '#clean' do

    let(:versions) {
      [
        '49b65b48a44ead62720c1c649db8fb529f730bed',
        'f15678d0862a572f898c54e50bc4f8e0bfcc5380',
        '0779ed758aacf70705206964a7ebe79231f4537b',
        'c5325c6a4bee73612f839b9b59e7bdfa566674cf',
        '45c508baf8fafa8475e1b14a2169e69a1b51c2cb',
      ]
    }
    let(:expected_files) do
      versions[0..3].map do |v|
        "application-%s.js" % v
      end
    end

    let(:unexpected_files) do
      [ "application-%s.js" % @asset_bundle_version ]
    end

    before(:each) do
      versions.each do |v|
        FileUtils.touch File.join(build_directory, "application-%s.js" % v)
        sleep 1 unless v == versions.last
      end
    end

    it 'keeps :keep_old_versions number of versions' do
      # This is what we're testing
      builder.clean

      expect(built_files).to include(*expected_files)
      expect(built_files).not_to include(*unexpected_files)
    end
  end

  context 'asset_helpers' do
    let(:index_read) { File.read File.join(build_directory, 'index.html') }

    it 'it compiles javascript tags to use bundled assets' do
      expect(index_read).to include(%{<script src="/application-#{@asset_bundle_version}.js"></script>})
    end

    it 'it compiles style tags to use bundled assets' do
      expect(index_read).to include(%{<link href="/application-#{@asset_bundle_version}.css" rel="stylesheet" type="text/css" media="all"></link>})
    end
  end
end
