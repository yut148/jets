module Jets
  class Inflector < Zeitwerk::Inflector
    def camelize(basename, _abspath)
      case basename
      when "cli"
        "CLI"
      when "io"
        "IO"
      else
        super
      end
    end
  end
end
