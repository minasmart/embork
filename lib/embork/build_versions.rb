module Embork::BuildVersions
  VERSION_FORMAT_EXP = /[a-f0-9]{40}\.js/

  def sorted_versions(project_root)
    build_path = File.join(project_root, 'build', Embork.env.to_s)

    versioned_files = []
    Find.find(build_path) do |file|
      versioned_files.push(file) if file.match VERSION_FORMAT_EXP
    end

    sorted_files = versioned_files.sort_by do |file|
      File.mtime file
    end

    versions = sorted_files.map { |f| version_name f }

    # Tidy up!
    versions.uniq.reverse
  end

  def version_name(filename)
    if match = filename.match(VERSION_FORMAT_EXP)
      match[0]
    else
      nil
    end
  end
end
