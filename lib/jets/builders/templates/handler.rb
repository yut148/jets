require "bundler/setup"
require "jets"
Jets.boot

<% @vars.functions.each do |function_name| -%>
def <%= function_name %>(event:, context:)
  Jets.process(event, context, "<%= @vars.handler_for(function_name) %>")
end
<% end %>
