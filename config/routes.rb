Rails.application.routes.draw do
  resources :start_numbers
  devise_for :users
  root to: 'dashboard#info'

  get '/timing' => 'dashboard#index'
  get '/live' => 'dashboard#live'
  post '/timesync' => 'dashboard#timesync'
  get '/info' => 'dashboard#info'
  get '/terms' => 'dashboard#terms'

  resources :clubs
  resources :categories
  resources :race_results do
    collection do
      match :from_device, via: [:get, :post]
      post :from_timing
      delete :destroy_from_timing
    end
  end
  resources :races do
    collection do
      get :get_live
    end
  end
  resources :racers do
    collection do
      get :login, to: 'racers#login_form'
      post :login
    end
  end
end
