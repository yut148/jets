# Interface:
#   subclasses must implement render
module Jets::Controller::Renderers
  class BaseRenderer
    delegate :request, :event, :headers, to: :controller
    attr_reader :controller
    def initialize(controller, options={})
      @controller = controller
      @options = options
    end

  private
    # From jets/controller/response.rb
    def drop_content_info?(status)
      status.to_i / 100 == 1 or drop_body?(status)
    end

    DROP_BODY_RESPONSES = [204, 304]
    def drop_body?(status)
      DROP_BODY_RESPONSES.include?(status.to_i)
    end

    # maps:
    #   :continue => 100
    #   :success => 200
    #   etc
    def normalize_status_code(code)
      status_code = if code.is_a?(Symbol)
                      Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
                    else
                      code
                    end
      (status_code || 200).to_s # API Gateway requires a string but rack is okay with either
    end
  end
end
