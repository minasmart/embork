require 'spec_helper'

require 'embork/sprockets/ember_handlebars_compiler'

require 'pry'


describe 'Embork::Sprockets::EmberHandlebarsCompiler' do
  let(:root_path) { File.expand_path('../ember_handlebars_compiler', __FILE__) }
  let(:global_hbs_specimen) { File.read(File.join(root_path, 'global_hbs_template.js')).strip }
  let(:global_handlebars_specimen) { File.read(File.join(root_path, 'global_handlebars_template.js')).strip }

  let(:app) do
    s = Sprockets::Environment.new root_path
    s.register_engine '.handlebars', Embork::Sprockets::EmberHandlebarsCompiler
    s.register_engine '.hbs', Embork::Sprockets::EmberHandlebarsCompiler
    s.append_path '.'
    Rack::Builder.new do
      run s
    end
  end

  it 'compiles handlebars source to ember handlebars' do
    get '/my_handlebars_template.js'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(global_handlebars_specimen)
  end

  it 'compiles hbs source to ember handlebars' do
    get '/my_hbs_template.js'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(global_hbs_specimen)
  end

  context 'CommonJS' do
    before(:all) { Embork::Sprockets::EmberHandlebarsCompiler.compile_to = :cjs }
    after(:all) { Embork::Sprockets::EmberHandlebarsCompiler.compile_to = :globals }

    let(:cjs_specimen) { File.read(File.join(root_path, 'cjs_template.js')).strip }

    it 'compiles hbs source to ember handlebars' do
      get '/my_hbs_template.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(cjs_specimen)
    end
  end

  context 'AMD' do
    before(:all) { Embork::Sprockets::EmberHandlebarsCompiler.compile_to = :amd }
    after(:all) { Embork::Sprockets::EmberHandlebarsCompiler.compile_to = :globals }

    let(:amd_specimen) { File.read(File.join(root_path, 'amd_template.js')).strip }

    it 'compiles hbs source to ember handlebars' do
      get '/my_hbs_template.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(amd_specimen)
    end
  end

  context 'Transformed names' do
    before(:all) do
      transform = Proc.new do |module_name|
        module_name.split('/').tap{ |parts| parts.shift }.join('_')
      end
      Embork::Sprockets::EmberHandlebarsCompiler.transform = transform
    end
    after(:all) { Embork::Sprockets::EmberHandlebarsCompiler.transform = nil }

    let(:transformed_specimen) { File.read(File.join(root_path, 'transformed_template.js')).strip }

    it 'transforms module names with a given proc' do
      get '/my/hbs/template.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(transformed_specimen)
    end
  end
end
