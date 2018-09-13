require 'action_view'

module Jets::Cfn::Ship
  class Empty < Base
    def run
      run_deployment
    end
    time :run
  end
end
