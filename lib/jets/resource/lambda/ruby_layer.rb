module Jets::Resource::Lambda
  class RubyLayer < LayerVersion
    def description
      "Jets Ruby Runtime"
    end

    def layer_name
      "jets-ruby-runtime"
    end

    def code_s3_key
      checksum = Jets::Builders::Md5.checksums["stage/opt"]
      "jets/code/opt-#{checksum}.zip" # s3_key
    end
  end
end
