# 0.0.13
- Remove the ability to have embork clean up old versions. This is better
  outsourced to your deployment solution. Also it was buggy.

# 0.0.12
- By default listen on 0.0.0.0 instead of localhost. 0.0.0.0 listens on all
  interfaces. Localhost only answers local requests to 127.0.0.1.
- Take out keyword arguments so that embork can run through rubinius.

# 0.0.11
- Fix a bug where it was impossible to forward requests between sprockets and a
  dynamic backend in development mode.

# 0.0.10
- Add project root to the extension. Rack applications that included it
  typically have a need to know.

# 0.0.9
- Change every instance of 'bundled_version' to 'bundle_version' for
  consistency.
- Add an extension class for external apps that may need erb helpers.

# 0.0.8
- Bump phrender version to 0.0.4
- Update bower depends in blueprint. Resolver and loader go up a version
