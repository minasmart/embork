require 'spec_helper'

require 'embork/sprockets/es6_module_transpiler'

describe 'Embork::Sprockets::ES6ModuleTranspiler' do
  let(:root_path) { File.expand_path '../es6_module_transpiler', __FILE__ }

  let(:app) do
    s = Sprockets::Environment.new root_path
    s.register_engine '.es6', Embork::Sprockets::ES6ModuleTranspiler
    s.append_path '.'
    Rack::Builder.new do
      run s
    end
  end

  let(:amd_specimen) { File.read(File.join(root_path, 'compiled_amd.js')).strip }
  let(:cjs_specimen) { File.read(File.join(root_path, 'compiled_cjs.js')).strip }
  let(:transformed_specimen) { File.read(File.join(root_path, 'transformed.js')).strip }

  it 'compiles to amd' do
    get '/my_fancy_module.js'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(amd_specimen)
  end

  context 'CJS Mode' do
    before(:all) { Embork::Sprockets::ES6ModuleTranspiler.compile_to = :cjs }
    after(:all) { Embork::Sprockets::ES6ModuleTranspiler.compile_to = :amd }

    it 'compiles to cjs' do
      get '/my_fancy_module.js'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(cjs_specimen)
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

    it 'compiler transforms module name' do
      get '/my/transformed/module.js'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(transformed_specimen)
    end
  end
end
