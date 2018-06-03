# Example of initializer file
# Customize only what you really need but notice that Pagy works also without any of the following lines.

# Extras
# See https://ddnexus.github.io/pagy/extras

# Array: Paginate arrays efficiently avoiding expensive array-wrapping and wihout overriding
# See https://ddnexus.github.io/pagy/extras/array
# require 'pagy/extras/array'

# Bootstrap: Nav helper and templates for Bootstrap pagination
# See https://ddnexus.github.io/pagy/extras/bootstrap
require 'pagy/extras/bootstrap'

# Compact: An alternative UI that combines the pagination with the nav info in one compact element
# See https://ddnexus.github.io/pagy/extras/compact
require 'pagy/extras/compact'

# I18n: Uses the `I18n` gem instead of the pagy implementation
# See https://ddnexus.github.io/pagy/extras/i18n
# require 'pagy/extras/i18n'

# Responsive: On resize, the number of page links will adapt in real-time to the available window or container width
# See https://ddnexus.github.io/pagy/extras/responsive
require 'pagy/extras/responsive'


# Pagy Variables
# All the Pagy::VARS here are set for all the pagy instances but can be
# overridden by just passing them to Pagy.new or the pagy controller method

# Core variables (See https://ddnexus.github.io/pagy/api/pagy#core-variables)
Pagy::VARS[:items] = 25

# Non Core Variables (See https://ddnexus.github.io/pagy/api/pagy#non-core-variables)
Pagy::VARS[:size]       = [5,4,4,5]
# Pagy::VARS[:page_param] = :page                           # default
# Pagy::VARS[:params]     = {}                              # default
# Pagy::VARS[:anchor]     = '#anchor'                       # example
# Pagy::VARS[:link_extra] = 'data-remote="true"'            # example
Pagy::VARS[:item_path]  = 'activerecord.models.dish'

# Extras Non Core Variables
# See https://ddnexus.github.io/pagy/extras/responsive#breakpoints
Pagy::VARS[:breakpoints] = { 0   => [1,2,2,1],
                             350 => [2,3,3,2],
                             550 => [3,4,4,3],
                             750 => [4,5,5,4],
                             950 => [5,6,6,5] }


# I18N Constant
# See https://ddnexus.github.io/pagy/api/frontend#i18n
# Pagy::I18N[:plurals] = -> (c) {([:zero, :one][c] || :other).to_s       # default

# just to check if :pagy_t works with a custom file with AR entries
Pagy::Frontend::I18N.load_file(Rails.root.join('config', 'locales', 'pagy.yml'))



# Rails: extras assets path required by compact or responsive extras
# See https://ddnexus.github.io/pagy/extras/compact and https://ddnexus.github.io/pagy/extras/responsive
Rails.application.config.assets.paths << Pagy.root.join('pagy', 'extras', 'javascripts')

