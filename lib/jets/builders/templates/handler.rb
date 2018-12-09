# TODO: would like to handle gems in layer instead of vendor/bundle
# But have to also account for gems that are using git repo
#
require "bundler/setup"
require "jets"
Jets.boot

def lambda_handler(event:, context:)
  puts "hi"
  puts "Jets.env #{Jets.env}"
  {test: "hello"}
end
