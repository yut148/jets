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
loader.ignore("#{__dir__}/core_ext/kernel")

dirs = %w[
  aws_services
  builders
  cfn
  commands
  controller
  core_ext
  generator
  internal
  job
  lambda
  mega
  middleware
  overrides
  poly_fun
  processors
  resource
  router
  rule
  spec_helpers
  stack
  turbo

  cli
  commands
  spec
  mailer.rb
]
dirs.each do |dir|
  loader.ignore("#{__dir__}/jets/#{dir}")
end

loader.setup # ready!

module Jets
  RUBY_VERSION = "2.5.3"
  class Error < StandardError; end
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
