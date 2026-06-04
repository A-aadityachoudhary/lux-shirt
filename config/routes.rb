Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :products
  root "products#index"
  resources :orders
  resources :cart, only: [:show, :destroy]
  resources :order_items do
    member do
      patch :increase_quantity
      patch :reduce_quantity
    end
  end

  resources :users
  namespace :admin do
    resources :products do
      member do
        patch :toggle_active
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
