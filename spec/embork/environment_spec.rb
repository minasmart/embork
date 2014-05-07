require 'spec_helper'
require 'embork/environment'

require 'ostruct'


describe 'Embork::Environment' do

  let(:my_processor) { class MyProcessor; end }

  let(:my_engine) { class MyEngine; end }

  let(:borkfile) { OpenStruct.new({
    :asset_paths => [ 'foo/bar/assets' ],
    :helpers => [ Proc.new { def my_helper; end; } ],
    :project_root => '/project_root',
    :sprockets_postprocessors => [
      { :mime_type => 'application/bork', :klass => my_processor }
    ],
    :sprockets_engines => [
      { :extension => '.bork', :klass => my_engine }
    ]
  })}

  let (:environment) { Embork::Environment.new borkfile }

  it 'respects the project root' do
    expect(environment.sprockets_environment.root).to eq('/project_root')
  end

  it 'respects asset paths' do
    expect(environment.sprockets_environment.paths).to include('/project_root/foo/bar/assets')
  end

  it 'adds helpers to the context class' do
    expect(environment.sprockets_environment.context_class.instance_methods).to include(:my_helper)
  end

  it 'adds post-processers by mime type' do
    expect(environment.sprockets_environment.postprocessors('application/bork')).to include(my_processor)
  end

  it 'adds engines my extension' do
    expect(environment.sprockets_environment.engines('.bork')).to eq(my_engine)
  end

  it 'uses a file-based persistent cache' do
    expect(environment.sprockets_environment.cache.class).to eq(Sprockets::Cache::FileStore)
  end
end
