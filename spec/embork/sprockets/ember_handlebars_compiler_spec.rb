require 'spec_helper'

require 'embork/sprockets/ember_handlebars_compiler'

describe 'Embork::Sprockets::EmberHandlebarsCompiler' do
  let(:root_path) { File.expand_path '../ember_handlebars_compiler', __FILE__ }

  let(:app) do
    s = Sprockets::Environment.new root_path
    s.register_engine '.handlebars', Embork::Sprockets::EmberHandlebarsCompiler
    s.register_engine '.hbs', Embork::Sprockets::EmberHandlebarsCompiler
    s.append_path '.'
    Rack::Builder.new do
      run s
    end
  end

  it "compiles handlebars source to ember handlebars" do
    get '/my_handlebars_template.js'
    expect(last_response).to be_ok
    expect(last_response.body).to eq("")
  end

  it "compiles hbs source to ember handlebars" do
    get '/my_hbs_template.js'
    expect(last_response).to be_ok
    expect(last_response.body).to eq("")
  end
end
