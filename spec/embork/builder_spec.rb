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
      'index.html'
    ]
  end

  before(:each) { @asset_bundle_version = builder.build }
  after(:each) { builder.clean }

  it 'builds assets' do
    expect(File.exists? build_directory).to be true

    generated_files = []
    Dir.glob(File.join(build_directory, '**/*')) do |file|
      if !File.directory? file
        path = Pathname.new(file)
        generated_files.push path.relative_path_from(Pathname.new build_directory).to_s
      end
    end
    expect(generated_files).to match_array(expected_files.map{ |f| f % [ @asset_bundle_version ] })
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
