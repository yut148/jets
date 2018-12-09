# const S3_BUCKET = '<%= @vars.s3_bucket %>';
# const RACK_ZIP = '<%= @vars.rack_zip %>';       // jets/code/rack-checksum.zip
# const BUNDLED_ZIP = '<%= @vars.bundled_zip %>'; // /tmp/bundled-checksum.zip
module Jets
  class LazyLoad
    include AwsServices

    def initialize(yaml_path=nil)
      yaml_path ||= "#{Jets.root}handlers/data.yml"
      @data = YAML.load_file(yaml_path)
      @s3_bucket = @data['s3_bucket']
      @zip_file = @data['rack_zip']
    end

    def load!
      rack
      # TODO: lazy load gems
    end

    def rack
      return unless Jets.rack?
      download_and_extract(@zip_file, '/tmp/rack')
    end

    def download_and_extract(zip_file, folder_dest)
      s3_key = "jets/code/#{zip_file}" # jets/code/rack-checksum.zip
      download_path = "/tmp/#{zip_file}" # /tmp/rack-checksum.zip

      download(s3_key, download_path)
      unzip(download_path, folder_dest)
    end

    def download(key, dest)
      # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#get_object-instance_method
      # stream object directly to disk
      s3.get_object(response_target: dest,
                    bucket: @s3_bucket,
                    key: key)
    end

    def unzip(zipfile, folder_dest)
      sh "unzip -qo #{zipfile} -d #{folder_dest}"
    end

    def sh(command)
      puts "=> #{command}"
      success = system(command)
      raise "Command #{command} failed" unless success
      success
    end
  end
end
