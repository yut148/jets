require 'action_view'

module Jets::Cfn::Ship
  class Full < Base
    include Jets::Timing
    include Jets::AwsServices
    include ActionView::Helpers::NumberHelper # number_to_human_size

    def initialize(options)
      @options = options
      @parent_stack_name = Jets::Naming.parent_stack_name
      @template_path = Jets::Naming.parent_template_path
    end

    def run
      upload_to_s3 # s3 bucket is available only when stack_type is full mode
      run_deployment
      prewarm
      show_api_endpoint
    end
    time :run

    def prewarm
      return unless @options[:stack_type] == :full # s3 bucket is available
      return unless Jets.config.prewarm.enable
      return if Jets::Commands::Build.poly_only?

      puts "Prewarming application..."
      if Jets::PreheatJob::CONCURRENCY > 1
        Jets::PreheatJob.perform_now(:torch, {quiet: true})
      else
        Jets::PreheatJob.perform_now(:warm, {quiet: true})
      end
    end

    def show_api_endpoint
      return unless @options[:stack_type] == :full # s3 bucket is available
      return if Jets::Router.routes.empty?
      resp, status = stack_status
      return if status.include?("ROLLBACK")

      resp = cfn.describe_stack_resources(stack_name: @parent_stack_name)
      resources = resp.stack_resources
      api_gateway = resources.find { |resource| resource.logical_resource_id == "ApiGateway" }
      stack_id = api_gateway["physical_resource_id"]

      resp = cfn.describe_stacks(stack_name: stack_id)
      stack = resp["stacks"].first
      output = stack["outputs"].find { |o| o["output_key"] == "RestApiUrl" }
      endpoint = output["output_value"]
      puts "API Gateway Endpoint: #{endpoint}"
    end

    # Upload both code and child templates to s3
    def upload_to_s3
      raise "Did not specify @options[:s3_bucket] #{@options[:s3_bucket].inspect}" unless @options[:s3_bucket]

      bucket_name = @options[:s3_bucket]

      puts "Uploading child CloudFormation templates to S3"
      expression = "#{Jets::Naming.template_path_prefix}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        key = "jets/cfn-templates/#{File.basename(path)}"
        obj = s3_resource.bucket(bucket_name).object(key)
        obj.upload_file(path)
      end

      md5_code_zipfile = Jets::Naming.md5_code_zipfile
      file_size = number_to_human_size(File.size(md5_code_zipfile))

      puts "Uploading #{md5_code_zipfile} (#{file_size}) to S3"
      start_time = Time.now
      key = Jets::Naming.code_s3_key
      obj = s3_resource.bucket(bucket_name).object(key)
      obj.upload_file(md5_code_zipfile)
      puts "Time to upload code to s3: #{pretty_time(Time.now-start_time).colorize(:green)}"
    end
    time :upload_to_s3
  end
end
