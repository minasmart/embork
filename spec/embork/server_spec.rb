require 'spec_helper'
require 'embork/server'

require 'base64'

project_root = File.expand_path '../server/example_app', __FILE__
borkfile_path = File.expand_path 'Borkfile', project_root
index_specimen = File.read File.expand_path('app/index.html', project_root)

image_path = File.expand_path 'static/images/image.png', project_root
image_data = IO.binread(image_path)

class MyRackBackend
  attr_reader :app
  def initialize(app = nil, options = {})
    @app = app
  end

  def call(env)
    body = %{You visited '%s'.} % [ env['PATH_INFO'] ]
    status = 200
    headers = Hash.new
    [ status, headers, body ]
  end
end

js_specimen = nil
File.open(File.expand_path('../server/specimen.js', __FILE__), 'r:UTF-8') { |f| js_specimen = f.read.strip }

css_specimen = nil
File.open(File.expand_path('../server/specimen.css', __FILE__), 'r:UTF-8') { |f| css_specimen = f.read.strip }

describe 'Embork::Server' do

  before(:each) { FileUtils.rm_rf File.join(project_root, '.cache') }
  let(:borkfile) { Embork::Borkfile.new borkfile_path }

  context 'pushState backed' do

    let(:server) { Embork::Server.new borkfile }
    let(:app) { server.app }

    it 'serves out compiled js' do
      get '/application.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(js_specimen)
    end

    it 'serves out compiled css' do
      get '/application.css'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(css_specimen)
    end

    it 'serves out static files' do
      get '/images/image.png'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(image_data)
    end

    it 'responds with index.html at the root path' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(index_specimen)
    end

    it 'responds with index.html for arbitrary paths' do
      get '/foo/bar'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(index_specimen)
    end

  end

  context 'rack backed' do
    let(:rack_backed_borkfile) { b = borkfile.dup; b.instance_eval { @backend = MyRackBackend }; b }
    let(:server) { Embork::Server.new rack_backed_borkfile }
    let(:app) { server.app }

    it 'serves out the index using the rack app' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(%{You visited '/'.})
    end

    it 'serves out arbitrary paths using rack' do
      get '/foo/bar'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(%{You visited '/foo/bar'.})
    end

    it 'continues to serve out sprockets assets' do
      get '/application.css'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(css_specimen)
    end
  end

  context 'bundled assets' do
    let(:server) { Embork::Server.new borkfile, :bundle_version => '12345' }
    let(:app) { server.app }

    it 'serves out bundled assets' do
      get '/application-12345.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(js_specimen)
    end

    it 'serves out the index' do
      get '/index.html'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(index_specimen)
    end

    it 'serves out the index for the root path' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(index_specimen)
    end

    it 'servers out the index for arbitrary paths' do
      get '/foo/bar'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(index_specimen)
    end
  end

  context 'bundled assets and rack backend' do
    let(:rack_backed_borkfile) { b = borkfile.dup; b.instance_eval { @backend = MyRackBackend }; b }
    let(:server) { Embork::Server.new rack_backed_borkfile, :bundle_version => '12345' }
    let(:app) { server.app }

    it 'serves out bundled assets' do
      get '/application-12345.js'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(js_specimen)
    end

    it 'serves out the index using the rack app' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(%{You visited '/'.})
    end

    it 'serves out arbitrary paths using rack' do
      get '/foo/bar'
      expect(last_response).to be_ok
      expect(last_response.body).to eq(%{You visited '/foo/bar'.})
    end

  end

  context 'test mode' do
    let(:server) { Embork::Server.new borkfile, :test_mode => true }
    let(:app) { server.app }

    it 'serves out the test index' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body.strip).to eq(%{test-index})
    end
  end
end
