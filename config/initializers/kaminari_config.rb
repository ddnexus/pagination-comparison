# frozen_string_literal: true
Kaminari.configure do |config|
  # config.default_per_page = 25
  # config.max_per_page = nil
  # config.window = 4
   config.outer_window = 5
  # config.left = 0
  # config.right = 0
  config.page_method_name = :kaminari_page
  # config.param_name = :page
  # config.params_on_first_page = false
end


# make it work with will_paginate
require 'kaminari/helpers/helper_methods'
Kaminari::Helpers::HelperMethods.send :alias_method, :kaminari_page_entries_info, :page_entries_info

# Kaminari hides its renderings by patching ActionView:
# the next 2 lines neutralize it and show all the partials rendered
require 'kaminari/actionview/action_view_extension.rb'
Kaminari::ActionViewExtension::LogSubscriberSilencer.send :remove_method, :render_partial

require 'kaminari/version'

