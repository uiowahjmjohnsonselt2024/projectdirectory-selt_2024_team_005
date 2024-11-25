Rails.application.routes.draw do
  resources :users, param: :username do
    member do
      get "buy_shards"
      post "process_payment"
    end
  end

  # Signup Routes
  get "signup", to: "users#new"
  post "signup", to: "users#create"

  # Forgot Password Routes
  get "forgot-password", to: "password_resets#new"
  post "forgot-password", to: "password_resets#create"
  get "forgot-password/edit", to: "password_resets#edit"
  patch "forgot-password/edit", to: "password_resets#update"

  # Sessions Routes (login/logout)
  get "login", to: "sessions#new"       # Show login form
  post "login", to: "sessions#create"    # Handle login form submission
  delete "logout", to: "sessions#destroy" # Handle logout (destroy session)

  # Home routes
  get "home", to: "home#index"

  # Root path (home page)
  root "sessions#new"  # You can adjust this to the actual home page path

  # Route for displaying all items in the store
  get "/store/:username", to: "store#shards_store", as: "store"

  # Route for purchasing an item
  post "/items/:username/:id/buy", to: "store#buy_item", as: "buy_item"

  resources :items, only: [ :show ] do
    post "buy", to: "store#buy_item", as: "buy_item"
  end

  # Character create and update
  post "create_character", to: "characters#create", as: "create_character"
  resources :characters, param: :username, only: [ :new, :create, :update ]

  # Grid and Cell routes
  resources :grids do
    member do
      patch :expand
    end
    resources :cells, only: [] do
      member do
        post "interact"
      end
    end
  end
  resources :cells, only: [ :show ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "/favicon.ico", to: redirect("/path/to/default/favicon.ico")

  # root "home#index"

  # Defines the root path route ("/")
  # root "posts#index"
end
