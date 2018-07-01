Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'comparison#index'

  get 'gems',  to: 'comparison#gems'
  get 'gems1', to: 'comparison#gems1'
  get 'gems2', to: 'comparison#gems2'

  get 'pagy',  to: 'comparison#pagy_action'
  get 'pagy1', to: 'comparison#pagy1'

  get 'screenshots', to: 'comparison#screenshots'
  get 'responsive_screencast', to: 'comparison#responsive_screencast'

end
