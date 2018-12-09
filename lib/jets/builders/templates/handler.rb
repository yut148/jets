require "bundler/setup"
require "jets"
Jets.boot

<% @vars.functions.each do |function_name| -%>
def <%= function_name %>(event:, context:)
  result = Jets::Processors::MainProcessor.new(JSON.dump(event), JSON.dump(context), "<%= @vars.handler_for(function_name) %>").run
  JSON.load(result)
end
<% end %>
