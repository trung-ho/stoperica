Rails.application.routes.draw do
  resources :race_admins
  resources :leagues, path: :natjecanja, param: :slug
  resources :pools
  devise_for :users
  root to: 'dashboard#info'

  get '/timing' => 'dashboard#index'
  get '/live' => 'dashboard#live'
  post '/timesync' => 'dashboard#timesync'
  get '/info' => 'dashboard#info'
  get '/terms' => 'dashboard#terms'
  get '/izjava' => 'dashboard#waiver'

  resources :clubs
  resources :categories
  resources :race_results do
    collection do
      match :from_device, via: [:get, :post]
      post :update_missed
      post :from_timing
      post :from_climbing
    end
  end
  resources :races do
    collection do
      get :get_live
    end
    member do
      get :assign_positions
      get :embed
    end
  end
  resources :racers do
    collection do
      get :login, to: 'racers#login_form'
      post :login
      get :search
    end
  end
  resources :start_numbers do
    collection do
     get :start_time
    end
  end
end
