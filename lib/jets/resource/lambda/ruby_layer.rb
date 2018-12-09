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
      "rubies/ruby-2.5.3.zip"
    end

    def s3_bucket
      "lambdagems2"
    end
  end
end
