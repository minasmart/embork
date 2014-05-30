require 'logger'
require 'colorize'

class Embork::Logger < ::Logger
  def initialize(stream, mode = :default)
    super(stream)
    @mode = mode
    if @mode == :simple
      self.formatter = simple_formatter
    end
  end

  protected

  def simple_formatter
    proc do |severity, datetime, progname, msg|
      if msg == :banner
        msg = ' ' + '=' * 79 + "\n"
      else
        msg.prepend '   '
        msg << "\n"
      end

      case severity
      when 'FATAL'
        msg.red.bold.swap
      when 'ERROR'
        msg.red
      when 'WARN'
        msg.yellow
      when 'INFO'
        msg.green
      when 'DEBUG'
        msg.magenta
      else
        msg
      end
    end
  end
end
