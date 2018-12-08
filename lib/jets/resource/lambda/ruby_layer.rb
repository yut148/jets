module Jets::Resource::Lambda
  class RubyLayer < LayerVersion
    def description
      "Jets Ruby Runtime"
    end

    def layer_name
      "jets-ruby-runtime"
    end

    def code_s3_key
      # checksum = Jets::Builders::Md5.checksums["stage/opt"]
      # "jets/code/ruby-#{checksum}.zip" # s3_key

      # Manually uploaded for testing
      # TODO: remove the hardcode
      # "jets/code/runtime-e73b3505.zip"
      "runtime.zip"
    end

    def s3_bucket
      "gems-test-2-us-west-2"
    end
  end
end
