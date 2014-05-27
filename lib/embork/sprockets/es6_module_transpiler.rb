require 'json'
require 'tilt'
require 'execjs'
require 'pathname'

require 'string/strip'

class Embork::Sprockets::ES6ModuleTranspiler < Tilt::Template

  class << self
    attr_accessor :compile_to
    attr_accessor :transform
    attr_accessor :namespace

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
  self.namespace = nil

  def prepare
    # Required to be implemented by Tilt for some reason...
  end

  def evaluate(scope, locals, &block)
    @environment = scope.environment
    @logical_path = scope.logical_path
    wrap_in_closure self.class.runtime.exec module_generator
  end

  def wrap_in_closure(compiled_code)
    if self.class.compile_to == :cjs
      <<-CJS.strip_heredoc % [ module_name, compiled_code ]
      window.require.define({"%s": function(exports, require, module) {

      %s

      }});
      CJS
    else
      compiled_code
    end
  end

  def source
    ::JSON.generate data, quirks_mode: true
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
