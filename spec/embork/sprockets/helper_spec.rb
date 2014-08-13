require 'spec_helper'

require 'embork/sprockets/helpers'

describe 'Embork::Sprockets::helpers' do
  let(:context_class) do
    class Context
      include Embork::Sprockets::Helpers
      extend Embork::Sprockets::Helpers::ClassMethods
    end
    Context.new
  end

  context '#javascript_include_tag' do
    it 'builds a root directory script tag' do
      expect(context_class.javascript_include_tag('application.js')).to eq(
        %{<script src="/application.js"></script>})
    end
  end

  context '#stylesheet_link_tag' do
    it 'builds a root directory link tag' do
      expect(context_class.stylesheet_link_tag('application.css')).to eq(
        %{<link href="/application.css" rel="stylesheet" type="text/css" media="all"></link>})
    end
  end

  context '#asset_path' do
    it 'pluralizes images' do
      expect(context_class.asset_path('image.png', :type => :image)).to eq(
        %{/images/image.png})
    end

    it 'pluralizes fonts' do
      expect(context_class.asset_path('font.eot', :type => :font)).to eq(
        %{/fonts/font.eot})
    end

    it 'doesn\t sub-directory javascripts' do
      expect(context_class.asset_path('file.js', :type => :javascript)).to eq(
        %{/file.js})
    end

    it 'doesn\t sub-directory stylesheets' do
      expect(context_class.asset_path('file.css', :type => :stylesheet)).to eq(
        %{/file.css})
    end

    it 'passes arbitrary types to named subdirectories' do
      expect(context_class.asset_path('file.mp3', :type => :audio)).to eq(
        %{/audio/file.mp3})
      expect(context_class.asset_path('file.avi', :type => :video)).to eq(
        %{/video/file.avi})
    end
  end

  context 'versioned assets' do
    before(:each) do
      context_class.class.use_bundled_assets = true
      context_class.class.bundle_version = '12345abcd'
    end

    context '#javascript_include_tag' do
      it 'builds a versioned script tag' do
        expect(context_class.javascript_include_tag('application.js')).to eq(
          %{<script src="/application-12345abcd.js"></script>})
      end
    end

    context '#stylesheet_link_tag' do
      it 'builds a versioned link tag' do
        expect(context_class.stylesheet_link_tag('application.css')).to eq(
          %{<link href="/application-12345abcd.css" rel="stylesheet" type="text/css" media="all"></link>})
      end
    end
  end
end
