# Embork

Build awesome hybrid EmberJS Apps! Embork is a build system for ember backed by
sprockets. It works like any conventional build system, but with a focus on
supporting multiple build targets. It also has a facility to develop with a
rack-compatible back-end providing the index.html file.

## Installation

Install it as a gem!

    $ gem install embork

## Usage

#### To create a new application:

    $ embork new my-app

#### Running the development server:

    $ embork server <environment>

The default environment is 'development'. There is also a production environment
included with the generator, however, you may create as many environments as you
want just by copying or creating a new folder under the `config` directory.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
