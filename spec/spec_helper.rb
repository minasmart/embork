require 'rack/test'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.include Rack::Test::Methods
end
