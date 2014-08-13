module Embork::Sprockets::Helpers
  module ClassMethods
    attr_accessor :use_bundled_assets
    attr_accessor :bundle_version
  end

  def javascript_include_tag(path)
    path = self.class.use_bundled_assets ? generate_versioned_name(path) : path
    script = asset_path(path, :type => :javascript)
    %{<script src="%s"></script>} % [ script ]
  end

  def javascript_embed_tag
  end

  def stylesheet_link_tag(path, options = {})
    options = { :media => :all }.merge options

    path = self.class.use_bundled_assets ? generate_versioned_name(path) : path
    stylesheet = asset_path(path, :type => :stylesheet)

    %{<link href="%s" rel="stylesheet" type="text/css" media="%s"></link>} % [
      stylesheet,
      options[:media].to_s
    ]
  end

  def stylesheet_embed_tag
  end

  def build_version
    if self.class.use_bundled_assets
      self.class.bundle_version
    else
      nil
    end
  end

  def namespace
    Embork::Sprockets::ES6ModuleTranspiler.namespace
  end

  def asset_path(path, options = {})
    base_path = '/'
    if !options.has_key? :type
      File.join base_path, path
    else
      type = options[:type]
      case type
      when :image
        File.join base_path, 'images', path
      when :font
        File.join base_path, 'fonts', path
      when :javascript
        File.join base_path, path
      when :stylesheet
        File.join base_path, path
      else
        File.join base_path, type.to_s, path
      end
    end
  end

  protected

  def generate_versioned_name(path_to_file)
    ext = File.extname path_to_file
    base = File.basename path_to_file, ext
    path = File.dirname path_to_file
    path = nil if path == '.'

    versioned_name = "%s-%s%s" % [ base, self.class.bundle_version, ext ]
    (path.nil?) ? versioned_name : File.join(path, versioned_name)
  end

end

