# Type: "AWS::Lambda::LayerVersion"
# Properties:
#   CompatibleRuntimes:
#     - String
#     - ...
#   Content:
#     Content
#   Description: String
#   LayerName: String
#   LicenseInfo: String
module Jets::Resource::Lambda
  class LayerVersion < Jets::Resource::Base
    def definition
      {
        layer_version_logical_id => {
          type: "AWS::Lambda::LayerVersion",
          properties: {
            compatible_runtimes: ["ruby2.5"],
            content: {
              s3_bucket: "!Ref S3Bucket",
              s3_key: code_s3_key,
              # s3_object_version: string,
            },
            description: description,
            layer_name: layer_name,
            license_info: "MIT",
          }
        }
      }
    end

    def layer_version_logical_id
      self.class.name.split('::').last
    end

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

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end
  end
end