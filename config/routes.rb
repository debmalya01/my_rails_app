Rails.application.routes.draw do
  devise_for :users
  # get 'garage_booking/index'
  # get 'garage_booking/edit'
  # get 'garage_booking/update'
  
  root to: 'home#index'

  get "/about", to: "home#about"

  resources :cars do
    resources :bookings, shallow: true
  end

  resources :garages, only: [:index, :show] do
    resources :bookings, only: [:index, :edit, :update], controller: 'garage_bookings'
  end
  
  get "up" => "rails/health#show", as: :rails_health_check

end
