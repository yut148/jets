module Jets::Resource::Lambda
  class GemLayer < LayerVersion
    def description
      "Jets Ruby Gems"
    end

    def layer_name
      "jets-ruby-gems"
    end

    def code_s3_key
      checksum = Jets::Builders::Md5.checksums["stage/opt"]
      "jets/code/opt-#{checksum}.zip" # s3_key
    end

  end
end
