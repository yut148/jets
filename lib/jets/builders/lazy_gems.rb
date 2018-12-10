class Jets::Builders
  class LazyGems
    LAMBDA_SIZE_LIMIT = 250 # Total lambda limit is 250MB

    include Util

    # When stage/code + stage/opt is the Lambda limit we'll create a stage/gems
    # and moved gems out out stage/opt to stage/gems. The stage/gems will be
    # lazy loaded into /tmp/jets and symlinked over. Example:
    #
    #   code/vendor/bundle/ruby/2.5.0/gems/hello-1.2.3 -> /tmp/ruby/gems/2.5.0/gems/hello-1.2.3
    #
    # TODO: for lazy gem loading
    # Move regular gems.
    # Move binary gems but only the gems, leave the .so extensions.
    def create
      display_sizes

      lazy_load_gems = !within_lambda_limit?(total_size)
      if lazy_load_gems
        puts "Code size + gems layer over lambda limit. Limit: #{LAMBDA_SIZE_LIMIT} Total size: #{total_size}"
        # lazy_creator = LazyGemsCreator.new
        # lazy_creator.create
        exit 1
      else
        puts "Code size + gems layer is within the limit"
      end

      symlink_gems(lazy_load_gems)
    end

    def symlink_gems(lazy)
      if lazy
        # Complex logic. For each lazy loaded gem we symlink:
        #
        #   code/vendor/bundle/ruby/2.5.0/gems/hello-1.2.3 -> /tmp/ruby/gems/2.5.0/gems/hello-1.2.3
        #   code/vendor/bundle/ruby/2.5.0/specifications/hello-1.2.3.gemspec -> /tmp/ruby/gems/2.5.0/gems/specifications/hello-1.2.3.gemspec
        #
        # For regular gems:
        #
        #   code/vendor/bundle/ruby/2.5.0/gems/hello-1.2.3 -> /opt/ruby/gems/2.5.0/gems/hello-1.2.3
        #   code/vendor/bundle/ruby/2.5.0/specifications/hello-1.2.3.gemspec -> /opt/ruby/gems/2.5.0/gems/specifications/hello-1.2.3.gemspec
        #
        # For common folders:
        #
        #   code/vendor/bundle/ruby/2.5.0/bin -> /opt/ruby/gems/2.5.0/bin
        #   code/vendor/bundle/ruby/2.5.0/build_info -> /opt/ruby/gems/2.5.0/build_info
        #   code/vendor/bundle/ruby/2.5.0/doc -> /opt/ruby/gems/2.5.0/doc
        #   code/vendor/bundle/ruby/2.5.0/extensions -> /opt/ruby/gems/2.5.0/extensions
        #
        # For bundler/gems (git source gems). Always move them to lazy loaded first. Since they are generally pretty big.
        #
        #   code/vendor/bundle/ruby/2.5.0/bundler -> /tmp/ruby/gems/2.5.0/bundler
        #
      else
        # Simple logic: vendor/bundle/ruby/2.5.0 -> /opt/ruby/gems/2.5.0
        ruby_folder = Jets::Gems.ruby_folder
        dest = "#{code_area}/vendor/bundle/ruby/#{ruby_folder}"
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.ln_sf("/opt/ruby/gems/#{ruby_folder}", dest)
      end
    end

    def display_sizes
      code_size = compute_size(code)
      opt_size = compute_size(opt)
      # ruby_layer_size = 125 * 1024 # TODO: calculate this from the download
      ruby_layer_size = 0
      total_size = opt_size + code_size + ruby_layer_size
      puts "code: #{megabytes(code_size)}"
      puts "opt: #{megabytes(opt_size)}"
      puts "total: #{megabytes(total_size)}"
      puts "remaining: #{megabytes(LAMBDA_SIZE_LIMIT * 1024 - total_size)}"
    end

    def within_lambda_limit?(total_size)
      # Jets Ruby Runtime is about 125MB right now
      total_size < LAMBDA_SIZE_LIMIT * 1024 # 120MB
    end

    def compute_size(path)
      out = `du -s #{path}`
      out.split(' ').first.to_i # bytes
    end

    def megabytes(bytes)
       n = bytes / 1024.0
       sprintf('%.1f', n) + 'MB'
    end
  end
end
