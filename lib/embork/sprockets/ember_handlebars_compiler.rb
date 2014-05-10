require 'barber'
require 'tilt'

class Embork::Sprockets::EmberHandlebarsCompiler < Tilt::Template
  class << self
    attr_accessor :compile_to
    attr_accessor :transform

    def closures(target)
      {
        :globals => "Ember.TEMPLATES['%s'] = %s",
        :cjs => '',
        :amd => ''
      }[target]
    end
  end
  self.default_mime_type = 'application/javascript'
  self.compile_to = :globals

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
      self.class.transform.call @logical_path
    else
      @logical_path
    end
  end

end
