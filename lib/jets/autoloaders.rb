module Jets
  module Autoloaders
    # Internal Jets Inflector
    class Inflector < Zeitwerk::Inflector
      def camelize(basename, _abspath)
        map = {
          cli: "CLI",
          io: "IO",
          version: "VERSION"
        }
        map[basename.to_sym] || super
      end
    end


    class << self
      extend Memoist

      def log!
        main.log!
        once.log!
      end

      def main
        Zeitwerk::Loader.new.tap do |loader|
          loader.tag = "jets.main"
          loader.inflector = Inflector.new # TODO: allow custom app inflector
        end
      end
      memoize :main

      def once
        Zeitwerk::Loader.new.tap do |loader|
          loader.tag = "jets.once"
          loader.inflector = Inflector.new

          loader.push_dir("#{__dir__}/..")
          paths = %w[
            internal/app/controllers
            internal/app/helpers
            internal/app/jobs
          ]
          paths.each do |path|
            loader.push_dir("#{__dir__}/#{path}")
          end

          ignore_paths.each do |path|
            loader.ignore("#{__dir__}/#{path}")
          end
        end
      end
      memoize :once

    private
      def ignore_paths
        # eager loading builders/rackup_wrappers - will cause the program to exit
        %w[
          builders/rackup_wrappers
          builders/reconfigure_rails
          builders/templates
          cli
          commands
          controller/middleware/webpacker_setup.rb
          core_ext
          generator
          internal
          internal/app/jobs/jets/preheat_job.rb
          mailer.rb
          overrides
          poly_fun
          processors
          resource
          router
          rule
          spec
          spec_helpers
          spec_helpers.rb
          stack
          turbo
        ]
      end
    end
  end
end
