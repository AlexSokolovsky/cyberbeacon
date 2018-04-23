Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'dashboard#index'

  resources :users, only: [:index, :show, :destroy]

  resources :devices do
  	post 'forward', on: :member
  	post 'custom', on: :member
  	post 'share', on: :member
  	resources :device_actions
  end


  resources :appliances do
    get 'connect', on: :member
  	post 'verify', on: :member
  end
end
