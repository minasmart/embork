class Embork::Pushstate
  attr_reader :app
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if status == 404
      env['PATH_INFO'] = '/index.html'
      @app.call(env)
    else
      [ status, headers, body ]
    end
  end
end
