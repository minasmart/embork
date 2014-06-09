require 'spec_helper'
require 'embork/environment'

require 'ostruct'


describe 'Embork::Environment' do

  let(:my_postprocessor) { class MyPostProcessor; end }
  let(:my_preprocessor) { class MyPreProcessor; end }

  let(:my_engine) { class MyEngine; end }

  let(:borkfile) { OpenStruct.new({
    :asset_paths => [ 'foo/bar/assets' ],
    :helpers => [ Proc.new { def my_helper; end; } ],
    :project_root => '/project_root',
    :sprockets_postprocessors => [
      { :mime_type => 'application/bork', :klass => my_postprocessor }
    ],
    :sprockets_preprocessors => [
      { :mime_type => 'application/bork', :klass => my_preprocessor }
    ],
    :sprockets_engines => [
      { :extension => '.bork', :klass => my_engine }
    ],
    :es6_namespace => 'my-package',
    :frameworks => [ 'bootstrap', 'compass' ],
    :compressor => :closure_compiler,
    :es6_transform => proc{ |name| name + 'foo' }
  })}

  let (:environment) { Embork::Environment.new borkfile }

  after(:all) do
    Embork::Sprockets::ES6ModuleTranspiler.namespace = nil
    Embork::Sprockets::ES6ModuleTranspiler.transform = nil
  end

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
    expect(environment.sprockets_environment.postprocessors('application/bork')).to include(my_postprocessor)
  end

  it 'adds pre-processers by mime type' do
    expect(environment.sprockets_environment.preprocessors('application/bork')).to include(my_preprocessor)
  end

  it 'adds engines my extension' do
    expect(environment.sprockets_environment.engines('.bork')).to eq(my_engine)
  end

  it 'uses a file-based persistent cache' do
    expect(environment.sprockets_environment.cache.class).to eq(Embork::Environment::ErblessCache)
  end

  it 'sets up a namespace on the es6 processor' do
    expect(Embork::Sprockets::ES6ModuleTranspiler.namespace).to eq('my-package')
  end

  it 'adds compass to the asset path' do
    expect(environment.sprockets_environment.paths.to_s).to match /\/compass-.*?\/frameworks\/compass\/stylesheets/
  end

  it 'adds bootstrap to the asset path' do
    expect(environment.sprockets_environment.paths.to_s).to match /\/bootstrap-sass-.*?\/vendor\/assets\/stylesheets/
  end

  it 'adds the Embork::Sprockets::ClosureCompiler as a bundle processor' do
    expect(environment.sprockets_environment.bundle_processors('application/javascript')).to include(Embork::Sprockets::ClosureCompiler)
  end

  it 'sets up an es6 transform' do
    expect(Embork::Sprockets::ES6ModuleTranspiler.transform.respond_to? :call).to eq(true)
  end

end
