class Jets::Builders
  class LambdaLayer
    include Util

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
      opt_original = "#{code_area}/opt"
      opt = "#{stage_area}/opt"
      FileUtils.mkdir_p(File.dirname(opt))
      FileUtils.mv(opt_original, opt)

      ruby_folder = Jets::Gems.ruby_folder
      gems_original = "#{code_area}/vendor/bundle/ruby/#{ruby_folder}"
      gems = "#{stage_area}/opt/ruby/gems/#{ruby_folder}"
      FileUtils.mkdir_p(File.dirname(gems))
      FileUtils.mv(gems_original, gems)
      # Deleting in this way to make sure folders are empty before we delete them
      FileUtils.rmdir("#{code_area}/vendor/bundle/ruby")
      FileUtils.rmdir("#{code_area}/vendor/bundle")
      FileUtils.rmdir("#{code_area}/vendor") if Dir.empty?("#{code_area}/vendor")
    end
  end
end
