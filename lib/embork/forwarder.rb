class Embork::Forwarder
  def self.target
    @target
  end

  def self.target=(target)
    @target = target
  end

  attr_reader :app
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if status == 404
      status, headers, body = self.class.target.new(@app).call(env)
      headers['Push-State-Redirect'] = 'true'
    end
    [ status, headers, body ]
  end
end
