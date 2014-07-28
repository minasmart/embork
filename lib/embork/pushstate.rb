class Embork::Pushstate
  attr_reader :app
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if status == 404
      modified_env = env.dup
      modified_env['PATH_INFO'] = '/index.html'
      status, headers, body = @app.call(modified_env)
      headers['Push-State-Redirect'] = 'true'
    end
    [ status, headers, body ]
  end
end
