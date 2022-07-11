Rails.application.routes.draw do

  resources :users, only: [:new, :create, :destroy, :edit, :update, :index]
  resources :sessions, only: [:new, :create, :index]
  resources :bouquets
  jsonapi_resources :flowers                                                                   #flowers objects such a api

  root to: 'sessions#new'
  get "vitrine", action: :bouquets_on_vitrine, controller: 'bouquets'
  delete "logout", action: :destroy, controller: 'sessions'
  get '/employee/:id', action: :employee, controller: 'users'
  get '/plus/:id', action: :plus, controller: 'bouquets'
  get '/minus/:id', action: :minus, controller: 'bouquets'
  get '/save/:id', action: :save, controller: 'bouquets'
  get '/add/:id', to: 'bouquets#add_in_bouquet'
  get 'sold', action: :sold, controller: 'bouquets'
  get 'removeall', action: :remove_all, controller: 'bouquets'
  get '/remove/:id', action: :remove, controller: 'bouquets'
  get 'profile', to: 'users#show'
  get 'admin', to: 'users#admin'

end
