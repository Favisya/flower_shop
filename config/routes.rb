Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  #
  resources :users, only: [:new, :create, :destroy, :edit, :update, :index]
  resources :sessions
  resources :bouquets
  jsonapi_resources :flowers
  # get '/bouquets/:id/add', to: 'bouquets#add_in_bouquet'
  get '/plus/:id', action: :plus, controller: 'bouquets'
  get '/minus/:id', action: :minus, controller: 'bouquets'
  get '/add/:id', action: :add_in_bouquet, controller: 'bouquets'
  get 'sold', action: :sold, controller: 'bouquets'
  get 'removeall', action: :remove_all, controller: 'bouquets'
  get '/remove/:id', action: :remove, controller: 'bouquets'
  get 'profile', to: 'users#show'
  get 'admin', to: 'users#admin'
  get 'flowerApi', to: 'flowers#flowerApi'
  # Defines the root path route ("/")
  # root "articles#index"
end
