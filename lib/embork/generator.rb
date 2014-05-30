require 'pathname'
require 'erb'
require 'open3'

require 'embork/logger'

class Embork::Generator
  attr_reader :erb_files
  attr_reader :dot_files
  attr_reader :project_path

  BLUEPRINT_DIR=File.expand_path('../../../blueprint', __FILE__).freeze

  def initialize(package_name, options)
    @package_name = package_name
    @logger = Embork::Logger.new STDOUT, :simple
    read_erb_files
    read_dot_files
    set_project_path(options[:directory])
  end

  def read_erb_files
    list_file_path = File.join(BLUEPRINT_DIR, 'erbfiles')
    @erb_files = File.readlines(list_file_path).map{ |f| f.strip }
  end

  def read_dot_files
    list_file_path = File.join(BLUEPRINT_DIR, 'dotfiles')
    @dot_files = File.readlines(list_file_path).map{ |f| f.strip }
  end

  def set_project_path(directory)
    if directory.nil?
      @project_path = File.join Dir.pwd, @package_name
    else
      p = Pathname.new directory
      if p.absolute?
        @project_path = p.to_s
      else
        @project_path = File.expand_path p.to_s, Dir.pwd
      end
    end
  end

  def generate
    check_for_npm
    print_banner
    copy_files
    process_erb
    move_dot_files
    install_npm_deps
    install_bower_deps
    print_success
  end

  protected
  attr_reader :logger

  def check_for_npm
    status = Open3.popen3('which npm') do |stdin, stdout, stderr, wait_thr|
      stdin.close
      wait_thr.value
    end
    if !status.success?
      logger.fatal :banner
      logger.warn "Hey Person! Embork needs node and npm installed to work properly."
      logger.warn "Come back and try again when you get them set up!"
      logger.fatal :banner
      exit 1
    end
  end

  def copy_files
    FileUtils.mkdir_p project_path
    FileUtils.cp_r File.join(BLUEPRINT_DIR, '.'), project_path
  end

  class ErbHelpers
    attr_accessor :namespace

    def get_binding
      binding
    end
  end

  def process_erb
    helpers = ErbHelpers.new
    helpers.namespace = @package_name
    Dir.chdir project_path do
      erb_files.each do |file|
        processed_file = ERB.new(File.read(file)).result helpers.get_binding
        File.open(file, 'w'){ |f| f.write processed_file }
      end
    end
  end

  def move_dot_files
    Dir.chdir project_path do
      dot_files.each do |file|
        FileUtils.mv file, '.%s' % file
      end
    end
  end

  def install_npm_deps
    logger.info 'Fetching npm dependencies.'
    command = 'npm install'
    out = status = nil
    Dir.chdir project_path do
      out = ''
      status = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        out = stdout.read + stderr.read
        wait_thr.value
      end
    end
    print_error(command, out) unless status.success?
  end

  def install_bower_deps
    logger.info 'Fetching bower dependencies.'
    command = 'npm run bower-deps'
    out = status = nil
    Dir.chdir project_path do
      out = ''
      status = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        out = stdout.read + stderr.read
        wait_thr.value
      end
    end
    print_error(command, out) unless status.success?
  end

  def print_error(command, trace)
    logger.fatal :banner
    logger.warn "The command '%s' failed to run." % command
    logger.debug "It failed with the following error:"
    logger.fatal :banner
    logger.debug trace
    exit 1
  end

  def print_banner
    logger.unknown :banner
    logger.info 'Setting up new embork project %s.' % @package_name
    logger.unknown :banner
    logger.unknown ''
  end

  def print_success
    logger.unknown :banner
    logger.info "Project setup in:"
    logger.unknown project_path.dup.prepend '  '
    logger.unknown ''
    logger.info "Your Embork project is ready to rock!"
    logger.info "`cd` into the project directory and type `embork server` to get started."
    logger.unknown :banner
    logger.unknown ''
  end

end
