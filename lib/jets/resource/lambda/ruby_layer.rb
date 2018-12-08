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

      # TODO: remove the hardcode
      #   s3://demo-dev-s3bucket-108423hnrqykk/jets/code/runtime-e73b3505.zip
      # Manually uploaded for testing
      "jets/code/runtime-e73b3505.zip"
    end
  end
end