Rails.application.routes.draw do
  use_doorkeeper
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }
  # get 'garage_booking/index'
  # get 'garage_booking/edit'
  # get 'garage_booking/update'
  
  root to: 'home#index'
  get "/about", to: "home#about"

  authenticate :user, lambda { |u| u.car_owner? } do
    resources :cars do
      resources :bookings, shallow: true
    end
  end

  authenticate :user, lambda { |u| u.garage_admin? } do
    resources :garages, only: [:index, :show] do
      resources :bookings, only: [:index, :edit, :update], controller: 'garage_bookings' do
        resources :invoices, only: [:show]
      end
    end
    

  end


  # API routes
  namespace :api do
    namespace :v1 do 
      get 'home', to: 'home#index'
      get 'about', to: 'home#about'
      
      resources :cars do
        resources :bookings, shallow: true
      end
      resources :garages, only: [:index, :show] do
        resources :bookings, only: [:index, :edit, :update], controller: 'garage_bookings' do
          resources :invoices, only: [:show]
        end
      end
      resource :garage_vehicle_brands, only: [:show, :update], path: 'garage-vehicle-brands'
      resources :service_types, only: [:index, :show]
      resources :vehicle_brands, only: [:index]
      resources :users, only: [:show, :update]
    end
  end
    
  mount ActionCable.server => '/cable'
  
  get "up" => "rails/health#show", as: :rails_health_check

end
