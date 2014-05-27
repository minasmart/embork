module Embork::Sprockets::Helpers
  module ClassMethods
    attr_accessor :use_bundled_assets
    attr_accessor :bundled_version
  end

  def javascript_include_tag(path)
    script = self.class.use_bundled_assets ? generate_versioned_name(path) : path
    %{<script src="%s"></script>} % [ script ]
  end

  def javascript_embed_tag
  end

  def stylesheet_link_tag(path, options = {})
    options = { :media => :all }.merge options

    stylesheet = self.class.use_bundled_assets ? generate_versioned_name(path) : path

    %{<link href="%s" rel="stylesheet" type="text/css" media="%s"></link>} % [
      stylesheet,
      options[:media].to_s
    ]
  end

  def stylesheet_embed_tag
  end

  def namespace
    Embork::Sprockets::ES6ModuleTranspiler.namespace
  end

  protected

  def generate_versioned_name(path_to_file)
    ext = File.extname path_to_file
    base = File.basename path_to_file, ext
    path = File.dirname path_to_file
    path = nil if path == '.'

    versioned_name = "%s-%s%s" % [ base, self.class.bundled_version, ext ]
    (path.nil?) ? versioned_name : File.join(path, versioned_name)
  end
end

