require 'spec_helper'

require 'embork/borkfile'
require 'embork/environment'
require 'embork/builder'

require 'pathname'

root_path = File.expand_path '../builder', __FILE__

describe 'Embork::Builder' do
  let(:borkfile) { Embork::Borkfile.new File.join(root_path, 'Borkfile'), :production }
  let(:builder) { Embork::Builder.new borkfile }
  let(:expected_files) do
    [
      'application.css',
      'application.js',
      'index.html',
      'deeply/nested/asset.js',
      'images/image.png',
    ]
  end

  before(:each) { @asset_bundle_version = builder.build }
  after(:each) { builder.clean @asset_bundle_version }

  it 'builds assets' do
    build_directory = File.join(root_path, 'build')
    expect(File.exists? build_directory).to be true

    generated_files = []
    Dir.glob(File.join(build_directory, '**/*')) do |file|
      if !File.directory? file
        path = Pathname.new(file)
        generated_files.push path.relative_path_from(Pathname.new build_directory).to_s
      end
    end
    expect(generated_files).to match_array(expected_files)
  end

  it 'compiles environment settings into files' do

  end
end
