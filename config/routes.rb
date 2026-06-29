Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/auth/login', to: 'auth#login'
      
      resources :brands, only: [:index] do
        member do
          get :products, to: 'brands#show_products'
        end
      end

      resources :products, only: [:index, :create, :update]
      resources :orders, only: [:create, :show] do
        member do
          patch :cancel
        end
      end
    end
  end
end