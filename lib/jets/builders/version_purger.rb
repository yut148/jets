# When upgrading jets, automatically rm -rf /tmp/jets in case the structure has changed.
class Jets::Builders
  class VersionPurger
    def initialize
      @version_file = "/tmp/jets/version.txt"
    end

    def purge
      if version_changed?
        last_version = @last_version || "unknown"
        puts "The jets version has changed since the last build. "
        puts "Current jets version: #{Jets::VERSION} Last built jets version: #{last_version}"
        puts "Removing entire /tmp/jets to start fresh."
        FileUtils.rm_rf("/tmp/jets")
      end
      write_version
    end

    # When jets changes versions
    def version_changed?
      return true unless File.exist?(@version_file)

      @last_version = IO.read(@version_file).strip
      @last_version != Jets::VERSION
    end

    def write_version
      FileUtils.mkdir_p(File.dirname(@version_file))
      IO.write(@version_file, Jets::VERSION)
    end
  end
end