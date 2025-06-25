Rails.application.routes.draw do
  
  root to: 'home#index'

  get "/about", to: "home#about"
  resources :cars do
    resources :bookings, shallow: true
  end
  
  get "up" => "rails/health#show", as: :rails_health_check

end
