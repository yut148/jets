# Builds the files required for later lazy loading by the node shim
#
#   lambdagems.json
#   rubygems.json
#   gitgems.json
#   submodulegems.json
#
class Jets::Builders
  class Lazy
    def build
      lambdagems
    end

    def lambdagems
      compiled_gems
    end

    def compiled_gems
      GemReplacer.new.compiled_gems
    end
  end
end