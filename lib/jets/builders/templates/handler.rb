require "bundler/setup"
require "jets"
Jets.boot

<% @vars.functions.each do |function_name| -%>
Jets.handler(self, "<%= @vars.handler_for(function_name) %>")
<% end %>
