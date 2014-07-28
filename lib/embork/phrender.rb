require 'phrender'
require 'embork/server'

class Embork::Phrender < Embork::Server

  def build_app
    if @borkfile.backend == :static_index
      backend = [ Phrender::RackMiddleware, {
        :javascript_files => @borkfile.phrender_javascript_paths,
        :javascript => @borkfile.phrender_raw_javascript,
        :index_file => @borkfile.phrender_index_file
      }]
    else
      Embork::Forwarder.target = @borkfile.backend
      backend = Embork::Forwarder
    end
    cascade_apps = @cascade_apps
    puts backend.inspect
    Rack::Builder.new do
      use *backend
      run Rack::Cascade.new(cascade_apps)
    end
  end

end
