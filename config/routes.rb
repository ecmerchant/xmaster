Rails.application.routes.draw do
  get 'accounts/regist'
  get 'accounts', to: 'accounts#regist'

  root :to =>'items#get'

  get 'items/get'
  get 'items', to: 'items#get'
  post 'items/get'

  #post 'items/upload', to: 'items#get'
  post 'items/upload'

  post 'accounts/regist'
  get 'accounts/regist'
  patch 'accounts/regist'

  get 'items/set'
  post 'items/set'

  get 'items/login_check'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
