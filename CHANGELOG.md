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
