class Jets::Builders
  class LazyGems
    LAMBDA_SIZE_LIMIT = 30 # Total lambda limit is 250MB

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

      lazy_load_gems = !within_lambda_limit?
      if lazy_load_gems
        puts "Code size + gems layer over lambda limit. Limit: #{LAMBDA_SIZE_LIMIT}MB Total size: #{megabytes(total_size)}"
        symlink_some_gems
      else
        puts "Code size + gems layer is within the limit"
        symlink_all_gems
      end

      display_sizes

      unless within_lambda_limit?
        code_size = compute_size("#{stage_area}/code")
        puts "Cannot fit code into AWS Lambda code size limit even after lazying loading all the gems.".colorize(:red)
        puts "Please reduce the size of your code.  The reduced code size after lazy loading gems is: #{megabytes(code_size)}"
        exit 1
      end
      puts "lazy_gems.rb exit early"
      exit 1
    end

    # Complex logic. We symlink gems to /tmp folder that is lazy loaded.
    #
    # For bundler/gems (git source gems). Always move them to lazy loaded first. Since they are generally pretty big.
    #
    #   /opt/ruby/gems/2.5.0/bundler -> /tmp/ruby/gems/2.5.0/bundler
    #
    # For regular gems:
    #
    #   /opt/ruby/gems/2.5.0/gems/hello-1.2.3 -> /opt/ruby/gems/2.5.0/gems/hello-1.2.3
    #   /opt/ruby/gems/2.5.0/specifications/hello-1.2.3.gemspec -> /opt/ruby/gems/2.5.0/gems/specifications/hello-1.2.3.gemspec
    #
    # For common folders leave as is
    #
    #   /opt/ruby/gems/2.5.0/bin
    #   /opt/ruby/gems/2.5.0/build_info
    #   /opt/ruby/gems/2.5.0/doc
    #   /opt/ruby/gems/2.5.0/extensions
    #
    def symlink_some_gems
      until within_lambda_limit? || @done_moving do
        move_gems
        @done_moving = done_moving?
      end
    end

    def move_gems
      move_bundler_gems
      move_normal_gem
    end

    def move_normal_gem
      gem_path = Dir.glob("#{stage_area}/opt/ruby/gems/2.5.0/gems/*").sort.find do |path|
        !File.symlink?(path)
      end
      return unless gem_path
      gem_name = File.basename(gem_path)
      create_symlink("gems/#{gem_name}")
      create_symlink("specifications/#{gem_name}.gemspec")
    end

    def done_moving?
      ruby_folder = "#{stage_area}/opt/ruby/gems/2.5.0"
      !File.exist?("#{ruby_folder}/bundler")# &&
      all_symlinks?("#{ruby_folder}/gems") &&
      all_symlinks?("#{ruby_folder}/specifications")
    end

    def all_symlinks?(folder)
      Dir.glob("#{folder}/*").reject { |p| File.symlink?(p) }.empty?
    end

    # Gem specifically under opt/ruby/gems/2.5.0/bundler
    def move_bundler_gems
      return if @move_bundler_gems
      create_symlink("bundler")
      @move_bundler_gems = true
    end

    # Moves the folder in /opt to /tmp and symlinks to it from /opt to /tmp.
    #
    # Parameter: relative_path within the ruby folder. IE: 2.5.0
    #
    # Example:
    #
    #   create_symlink("bundler")
    #   =>
    #   /opt/ruby/gems/2.5.0/bundler -> /tmp/gems/2.5.0/bundler
    #
    def create_symlink(path)
      src = "#{stage_area}/opt/ruby/gems/2.5.0/#{path}"
      dest = "#{stage_area}/gems/2.5.0/#{path}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.mv(src, dest)
      # puts "ln -sf #{dest} #{src}" # uncomment to see and debug
      FileUtils.ln_sf(dest, src)
    end

    def within_lambda_limit?
      total_size < LAMBDA_SIZE_LIMIT * 1024 # 120MB
    end

    def total_size
      code_size = compute_size("#{stage_area}/code")
      opt_size = compute_size("#{stage_area}/opt")
      opt_size + code_size # total_size
    end

    # Simple logic: vendor/bundle/ruby/2.5.0 -> /opt/ruby/gems/2.5.0
    def symlink_all_gems
      ruby_folder = Jets::Gems.ruby_folder
      dest = "#{code_area}/vendor/bundle/ruby/#{ruby_folder}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.ln_sf("/opt/ruby/gems/#{ruby_folder}", dest)
    end

    def display_sizes
      code_size = compute_size("#{stage_area}/code")
      opt_size = compute_size("#{stage_area}/opt")
      total_size = opt_size + code_size
      puts "code: #{megabytes(code_size)}"
      puts "opt: #{megabytes(opt_size)}"
      puts "total: #{megabytes(total_size)}"
      puts "remaining: #{megabytes(LAMBDA_SIZE_LIMIT * 1024 - total_size)}"
      sh "du -csh /tmp/jets/demo/stage/*"
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
