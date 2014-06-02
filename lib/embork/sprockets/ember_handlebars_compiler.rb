require 'barber'
require 'tilt'

require 'string/strip'

class Embork::Sprockets::EmberHandlebarsCompiler < Tilt::Template
  class << self
    attr_accessor :compile_to
    attr_accessor :transform
    attr_accessor :namespace

    CJS_closure = <<-CJS.strip_heredoc
      window.require.define({"%s": function(exports, require, module) {

      "use strict";
      var template = %s

      exports["default"] = template;

      }});
    CJS

    AMD_closure = <<-AMD.strip_heredoc
      define("%s",
        ["exports"],
        function(__exports__) {

      "use strict";
      var template = %s

      __exports__["default"] = template;

      });
    AMD

    def closures(target)
      {
        :globals => "Ember.TEMPLATES['%s'] = %s",
        :cjs => CJS_closure,
        :amd => AMD_closure
      }[target]
    end
  end
  self.namespace = nil
  self.default_mime_type = 'application/javascript'
  self.compile_to = :amd

  def prepare
    # Required to be implemented by Tilt for some reason...
  end

  def evaluate(scope, locals, &block)
    @environment = scope.environment
    @logical_path = scope.logical_path
    template = Barber::Ember::FilePrecompiler.call(data)
    closure = self.class.closures(self.class.compile_to)
    closure % [ module_name, template ]
  end

  def module_name
    if self.class.transform
      name = self.class.transform.call @logical_path
    else
      name = @logical_path
    end

    # Attach the namespace
    if !self.class.namespace.nil?
      "%s/%s" % [ self.class.namespace.to_s, name ]
    else
      name
    end
  end

end
