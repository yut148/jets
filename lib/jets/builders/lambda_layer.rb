class Jets::Builders
  class LambdaLayer
    LAMBDA_SIZE_LIMIT = 250 # Total lambda limit is 250MB

    # At this point we gems have all been moved to stage/code/vendor/bundle, this includes
    # binary gems, a good state. This method moves them:
    #
    #   from stage/code/vendor/bundle/ruby/2.5.0
    #   to stage/opt/ruby/gems/2.5.0
    #
    # This is done because we want to get as many gems into the Lambda Layer as possible.
    #
    # Important folders later:
    #
    #   stage/code/opt/lib
    #   stage/code/opt/ruby
    #
    def build
      code = "#{Jets.build_root}/stage/code"
      opt_original = "#{code}/opt"
      opt = "#{Jets.build_root}/stage/opt"
      FileUtils.mkdir_p(File.dirname(opt))
      FileUtils.mv(opt_original, opt)

      ruby_folder = Jets::Gems.ruby_folder
      gems_original = "#{code}/vendor/bundle/ruby/#{ruby_folder}"
      gems = "#{Jets.build_root}/stage/opt/ruby/gems/#{ruby_folder}"
      FileUtils.mkdir_p(File.dirname(gems))
      FileUtils.mv(gems_original, gems)
      # Deleting in this way to make sure folders are empty before we delete them
      FileUtils.rmdir("#{code}/vendor/bundle/ruby")
      FileUtils.rmdir("#{code}/vendor/bundle")
      FileUtils.rmdir("#{code}/vendor") if Dir.empty?("#{code}/vendor")

      code_size = compute_size(code)
      opt_size = compute_size(opt)
      # ruby_layer_size = 125 * 1024 # TODO: calculate this from the download
      ruby_layer_size = 0
      total_size = opt_size + code_size + ruby_layer_size
      puts "code: #{megabytes(code_size)}"
      puts "opt: #{megabytes(opt_size)}"
      puts "total: #{megabytes(total_size)}"
      puts "remaining: #{megabytes(LAMBDA_SIZE_LIMIT * 1024 - total_size)}"

      if within_lambda_limit?(total_size)
        puts "Gems Layer Size is within the limit"
      else
        raise "lambda layer is too large"
      end
    end
    # TODO: for lazy gem loading
    # Move regular gems.
    # Move binary gems but only the gems, leave the .so extensions.

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
