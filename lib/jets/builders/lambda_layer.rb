class Jets::Builders
  class LambdaLayer
    # Important folders:
    #
    #   stage/code/opt/linux
    #   stage/code/vendor/bundle/ruby/2.5.0/gems
    #
    def build
      code = "#{Jets.build_root}/stage/code"
      opt_original = "#{code}/opt"
      opt = "#{Jets.build_root}/stage/opt"
      FileUtils.mv(opt_original, opt)

      ruby_folder = Jets::Gems.ruby_version_folder
      gems_original = "#{code}/vendor/bundle/ruby/#{ruby_folder}"
      gems = "#{Jets.build_root}/stage/opt/ruby/gems/#{ruby_folder}"
      FileUtils.mkdir_p(File.dirname(gems))
      FileUtils.mv(gems_original, gems)
      FileUtils.rmdir("#{code}/vendor/bundle/ruby")
      FileUtils.rmdir("#{code}/vendor/bundle")
      FileUtils.rmdir("#{code}/vendor") if Dir.empty?("#{code}/vendor")

      code_size = compute_size(code)
      opt_size = compute_size(opt)
      total_size = opt_size + code_size

      if within_lambda_limit?(total_size)
        puts "Gems Layer Size is within the limit"
      else
        raise "lambda layer is too large"
      end

      puts "code: #{megabytes(code_size)}"
      puts "opt: #{megabytes(opt_size)}"
      puts "total: #{megabytes(total_size)}"
      puts "remaining: #{megabytes(125 * 1024 - total_size)}"
    end

    # TODO: for lazy gem loading
    # Move regular gems.
    # Move binary gems but only the gems, leave the .so extensions.

    def within_lambda_limit?(total_size)
      limit_in_mb = 125 # 125MB because jets ruby runtime is 125MB. Total lambda limit is 250MB
      limit = limit_in_mb - 5 # 5MB buffer
      total_size < limit * 1024 # 120MB -
    end

    def compute_size(path)
      out = `du -s #{path}`
      out.split(' ').first.to_i # bytes
    end

    def megabytes(bytes)
       n = bytes / 1024.0
       sprintf('%.1f', n) + 'MB'
    end

    # TODO: only do this shuffling if lazy load
    # Move bundled to opt/bundled folder in preparation for zipping up opt.zip
    # instead of bundled.zip
    def move_bundled_under_opt
      FileUtils.mkdir_p("#{stage_area}/opt") # /tmp/jets/demo/stage/opt
      # mv /tmp/jets/demo/stage/code/bundled /tmp/jets/demo/stage/opt/bundled
      FileUtils.mv("#{full(tmp_code)}/bundled", "#{stage_area}/opt/bundled")
    end

    # setup_symlinks # TODO: figure out /tmp/rack

  end
end
