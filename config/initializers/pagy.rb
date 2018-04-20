# We try to exercise all the variables and extras with this initializer

# regular pagy vars
Pagy::VARS[:items]     = 25
Pagy::VARS[:size]      = [5,4,4,5]
Pagy::VARS[:item_path] = 'activerecord.models.dish' # single model in app, so use a global var

# this is a single-language app, we want to use the faster pagy implementation
Pagy::I18N[:gem]  = false
# just to check if :pagy_t works with a custom file with AR entries
Pagy::I18N[:file] = Rails.root.join('config', 'locales', 'pagy.yml')

# we use "require: false" for the pagy-ext in the Gemfile, so we require it here (after the I18n setup)
require 'pagy-extras'
# add extras assets path
Rails.application.config.assets.paths << Pagy.extras_root.join('javascripts')
Pagy::VARS[:breakpoints] = {0 => [1,2,2,1], 350 => [2,3,3,2], 550 => [3,4,4,3], 750 => [4,5,5,4], 950 => [5,6,6,5]}
