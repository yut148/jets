$:.unshift(File.expand_path("../", __FILE__))
require "active_support"
require "active_support/concern"
require "active_support/core_ext"
require "active_support/dependencies"
require "active_support/ordered_hash"
require "active_support/ordered_options"
require "fileutils"
require "memoist"
require "rainbow/ext/string"
require "zeitwerk"

require "jets/camelizer"
require "jets/inflector"
require "jets/version"

loader = Zeitwerk::Loader.for_gem

loader.inflector = Jets::Inflector.new
loader.logger = method(:puts)

loader.ignore("#{__dir__}/jets/internal")

loader.push_dir("#{__dir__}/jets/internal/app/controllers")
loader.push_dir("#{__dir__}/jets/internal/app/helpers")
loader.push_dir("#{__dir__}/jets/internal/app/jobs")

loader.ignore("#{__dir__}/jets/internal/app/jobs/jets/preheat_job.rb")
loader.ignore("#{__dir__}/jets/controller/middleware/webpacker_setup.rb")
loader.ignore("#{__dir__}/jets/builders/templates")



loader.setup # ready!

module Jets
  RUBY_VERSION = "2.5.3"
  class Error < StandardError; end

  # autoload :Application, "jets/application"
  # autoload :AwsInfo, "jets/aws_info"
  # autoload :AwsServices, "jets/aws_services"
  # autoload :Booter, 'jets/booter'
  # autoload :Builders, 'jets/builders'
  # autoload :Call, "jets/call"
  # autoload :Cfn, 'jets/cfn'
  # autoload :CLI, "jets/cli"
  # autoload :Commands, "jets/commands"
  # autoload :Controller, 'jets/controller'
  # autoload :Core, "jets/core"
  # autoload :Db, 'jets/db'
  # autoload :Dotenv, 'jets/dotenv'
  # autoload :Erb, "jets/erb"
  # autoload :Generator, "jets/generator"
  # autoload :Inflections, "jets/inflections"
  # autoload :IO, "jets/io"
  # autoload :Job, 'jets/job'
  # autoload :Klass, 'jets/klass'
  # autoload :Lambda, 'jets/lambda'
  # autoload :Logger, "jets/logger"
  # autoload :Mailer, "jets/mailer"
  # autoload :Mega, "jets/mega"
  # autoload :Middleware, "jets/middleware"
  # autoload :Naming, 'jets/naming'
  # autoload :PolyFun, 'jets/poly_fun'
  # autoload :Preheat, "jets/preheat"
  # autoload :Processors, 'jets/processors'
  # autoload :RackServer, "jets/rack_server"
  # autoload :Rdoc, "jets/rdoc"
  # autoload :Resource, "jets/resource"
  # autoload :Route, "jets/route"
  # autoload :Router, "jets/router"
  # autoload :Rule, 'jets/rule'
  # autoload :Stack, "jets/stack"
  # autoload :TmpLoader, "jets/tmp_loader"
  # autoload :Turbine, 'jets/turbine'
  # autoload :Turbo, 'jets/turbo'
  # autoload :Util, "jets/util"

  extend Core # root, logger, etc
end

require "jets/core_ext/kernel"

root = File.expand_path("..", File.dirname(__FILE__))

$:.unshift("#{root}/vendor/jets-gems/lib")
require "jets-gems"

$:.unshift("#{root}/vendor/rails/actionpack/lib")
$:.unshift("#{root}/vendor/rails/actionview/lib")
# will require action_controller, action_pack, etc later when needed

Jets::Db # trigger autoload

puts "eager_load start".color(:yellow)
loader.eager_load
puts "eager_load end".color(:yellow)
