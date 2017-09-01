Rails.application.routes.draw do
  get 'items/get'
  get 'items', to: 'items#get'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
