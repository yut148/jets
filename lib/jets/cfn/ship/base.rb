require 'action_view'

module Jets::Cfn::Ship
  class Base
    include Jets::Timing
    include Jets::AwsServices
    include ActionView::Helpers::NumberHelper # number_to_human_size

    def initialize(options)
      @options = options
      @parent_stack_name = Jets::Naming.parent_stack_name
      @template_path = Jets::Naming.parent_template_path
    end

    def run_deployment
      stack_in_progress?(@parent_stack_name)

      puts "Deploying CloudFormation stack with jets app!"
      begin
        save_stack
      rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => e
        capabilities = e.message.match(/\[(.*)\]/)[1]
        confirm = prompt_for_iam(capabilities)
        if confirm =~ /^y/
          @options.merge!(capabilities: [capabilities])
          puts "Re-running: #{command_with_iam(capabilities).colorize(:green)}"
          retry
        else
          puts "Exited"
          exit 1
        end
      end

      wait_for_stack
    end

    def save_stack
      if stack_exists?(@parent_stack_name)
        update_stack
      else
        create_stack
      end
    end

    def create_stack
      # parent stack template is on filesystem and child stacks templates is on s3
      IO.read(@template_path) # template_body
      cfn.create_stack(stack_options)
    end
    time :create_stack

    def update_stack
      begin
        cfn.update_stack(stack_options)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        puts "ERROR: #{e.message}".red
        true # error = true
      end
    end
    time :update_stack

    # options common to both create_stack and update_stack
    def stack_options
      {
        stack_name: @parent_stack_name,
        template_body: IO.read(@template_path),
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
        # disable_rollback: !@options[:rollback],
      }
    end

    # check for /(_COMPLETE|_FAILED)$/ status
    def wait_for_stack
      Jets::Cfn::Status.new(@options).wait
    end
    time :wait_for_stack

    # All CloudFormation states listed here:
    # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def stack_status
      resp = cfn.describe_stacks(stack_name: @parent_stack_name)
      status = resp.stacks[0].stack_status
      [resp, status]
    end

    def prompt_for_iam(capabilities)
      puts "This stack will create IAM resources.  Please approve to run the command again with #{capabilities} capabilities."
      puts "  #{command_with_iam(capabilities)}"

      puts "Please confirm (y/n)"
      $stdin.gets # confirm
    end

    def command_with_iam(capabilities)
      "#{File.basename($0)} #{ARGV.join(' ')} --capabilities #{capabilities}"
    end

    def capabilities
      ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"] # TODO: remove capabilities hardcode
      # return @options[:capabilities] if @options[:capabilities]
      # if @options[:iam]
      #   ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      # end
    end

    # http://stackoverflow.com/questions/4175733/convert-duration-to-hoursminutesseconds-or-similar-in-rails-3-or-ruby
    def pretty_time(total_seconds)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      if total_seconds < 60
        "#{seconds.to_i}s"
      else
        "#{minutes.to_i}m #{seconds.to_i}s"
      end
    end

  end
end
