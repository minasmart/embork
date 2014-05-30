require 'spec_helper'
require 'embork/generator'

describe 'Embork::Generator' do

  let(:app_name) { 'my-app' }
  let(:working_dir) { File.expand_path '../generator', __FILE__ }
  let(:project_dir) { File.join working_dir, app_name }
  let(:generator) do
    Embork::Generator.new app_name, {
      :use_ember_data => false,
      :directory => project_dir
    }
  end

  it 'loads the list of files to be processed by ERB' do
    expect(generator.erb_files).to match_array([
      "Borkfile", "app/app.js", "app/index.html.erb", "bower.json", "package.json"
    ])
  end

  it 'loads the list of files to be moved to dot-files' do
    expect(generator.dot_files).to match_array([
      "bowerrc", "gitignore", "jshintrc"
    ])
  end

  it 'defaults to the correct directory' do
    expect(generator.project_path).to eq(project_dir)
  end

  context '#project_path' do
    it 'defaults to a path named for the package, relative to the caller' do
      g = Embork::Generator.new(app_name, use_ember_data: false, directory: nil)
      expected_path = File.join(Dir.pwd, app_name)
      expect(g.project_path).to eq(expected_path)
    end

    it 'expands a relative path' do
      directory = 'some/other/dir'
      g = Embork::Generator.new(app_name, use_ember_data: false, directory: directory)
      expected_path = File.expand_path directory, Dir.pwd
      expect(g.project_path).to eq(expected_path)
    end
  end

  context '#generate' do
    before(:each) { generator.generate }
    after(:each) { FileUtils.rm_rf project_dir }

    it 'generates a blank project' do
      Dir.chdir project_dir do
        files = [ '.',
                  '..',
                  '.bowerrc',
                  '.gitignore',
                  '.jshintrc',
                  'Borkfile',
                  'Gemfile',
                  'README.md',
                  'app',
                  'bower.json',
                  'components',
                  'config',
                  'dotfiles',
                  'erbfiles',
                  'node_modules',
                  'package.json',
                  'static',
                  'tests' ]
        expect(Dir.glob('*', File::FNM_DOTMATCH)).to match_array(files)
      end
    end

    it 'processes erb' do
      Dir.chdir project_dir do
        expect(File.read('app/app.js')).to include('my-app')
      end
    end
  end

end
