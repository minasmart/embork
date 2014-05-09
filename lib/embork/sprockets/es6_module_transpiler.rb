require 'json'
require 'tilt'
require 'execjs'
require 'pathname'

class Embork::Sprockets::ES6ModuleTranspiler < Tilt::Template

  class << self
    attr_accessor :compile_to
    attr_accessor :transform

    def transpiler_path
      File.expand_path '../support/es6-module-transpiler.js', __FILE__
    end

    def runner_path
      File.expand_path '../support/node_runner.js', __FILE__
    end

    def runtime
      ExecJS::ExternalRuntime.new(
        name: 'Node.js (V8)',
        command: [ 'nodejs', 'node' ],
        encoding: 'UTF-8',
        runner_path: runner_path
      )
    end
  end
  self.compile_to = :amd
  self.default_mime_type = 'application/javascript'

  def prepare
    # Required to be implemented by Tilt for some reason...
  end

  def evaluate(scope, locals, &block)
    @environment = scope.environment
    @logical_path = scope.logical_path
    self.class.runtime.exec module_generator
  end

  def source
    ::JSON.generate data, quirks_mode: true
  end

  def module_name
    if self.class.transform
      self.class.transform.call @logical_path
    else
      @logical_path
    end
  end

  def module_type
    self.class.compile_to.to_s.upcase
  end

  def module_generator
    <<-SOURCE % [ self.class.transpiler_path, source, module_name, module_type ]
    var Compiler = require("%s").Compiler;
    var module = (new Compiler(%s, "%s"));
    return module.to%s();
    SOURCE
  end

end
