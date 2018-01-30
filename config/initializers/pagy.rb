Pagy::VARS[:items]     = 25
Pagy::VARS[:initial]   = 5
Pagy::VARS[:final]     = 5
Pagy::VARS[:item_path] = 'activerecord.models.dish' # single model in app, so use a global var

# this is a single-language app, we want to use the faster pagy implementation
Pagy::I18N[:gem]  = false
# just to check if :pagy_t works with a custom file with AR entries
Pagy::I18N[:file] = Rails.root.join('config', 'locales', 'pagy.yml')
