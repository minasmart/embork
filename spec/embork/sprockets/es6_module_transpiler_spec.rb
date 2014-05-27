require 'spec_helper'

require 'embork/sprockets/es6_module_transpiler'

describe 'Embork::Sprockets::ES6ModuleTranspiler' do
  let(:root_path) { File.expand_path '../es6_module_transpiler', __FILE__ }

  let(:sprockets_environment) { Sprockets::Environment.new root_path }
  let(:app) do
    s = sprockets_environment
    s.register_preprocessor 'application/javascript', Embork::Sprockets::ES6ModuleTranspiler
    s.append_path '.'
    Rack::Builder.new do
      run s
    end
  end

  let(:amd_specimen) { File.read(File.join(root_path, 'compiled_amd.js')).strip }

  it 'compiles to amd' do
    get '/my_fancy_module.js'
    expect(last_response).to be_ok
    expect(last_response.body.strip).to eq(amd_specimen)
  end

  context 'CJS Mode' do
    before(:all) { Embork::Sprockets::ES6ModuleTranspiler.compile_to = :cjs }
    after(:all) { Embork::Sprockets::ES6ModuleTranspiler.compile_to = :amd }

    let(:cjs_specimen) { File.read(File.join(root_path, 'compiled_cjs.js')).strip }

    it 'compiles to cjs' do
      get '/my_fancy_module.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(cjs_specimen)
    end
  end

  context 'With Transform' do
    before(:all) do
      transform = Proc.new do |module_name|
        module_name.split('/').tap{ |parts| parts.shift }.join('_')
      end
      Embork::Sprockets::ES6ModuleTranspiler.transform = transform
    end

    after(:all) { Embork::Sprockets::ES6ModuleTranspiler.transform = nil }

    let(:transformed_specimen) { File.read(File.join(root_path, 'transformed.js')).strip }

    it 'transforms module name' do
      get '/my/transformed/module.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(transformed_specimen)
    end
  end

  context 'With namespace' do

    before(:all) do
      Embork::Sprockets::ES6ModuleTranspiler.namespace = 'my-package'
    end

    after(:all) do
      Embork::Sprockets::ES6ModuleTranspiler.namespace = nil
    end

    let(:namespaced_specimen) { File.read(File.join(root_path, 'namespaced.js')).strip }

    it 'adds a namespace to the module name' do
      get '/my_fancy_module.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(namespaced_specimen)
    end

  end
end
