module Embork::BuildVersions
  VERSION_FORMAT_EXP = /\d{4}\.\d{2}\.\d{2}\.\d{2}\.\d{2}\.\d{2}\.\d{4}/

  def sorted_versions(project_root)
    build_path = File.join(project_root, 'build', Embork.env.to_s)

    versions = []
    Find.find(build_path) do |file|
      version = version_name(file)
      versions.push version if version
    end

    # Tidy up!
    versions.uniq!.sort!.reverse!
  end

  def version_name(filename)
    m = File.basename(filename).match VERSION_FORMAT_EXP
    m.nil? ? false : m[0]
  end
end
