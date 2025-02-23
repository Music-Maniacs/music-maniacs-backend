Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
               passwords: 'users/passwords',
               confirmations: 'users/confirmations'
             }

  resource :profile, controller: 'user_profiles',only: %i[destroy] do
    get :info
    put :update
    put :change_password
    get :show_followed_artists
    get :show_followed_producers
    get :show_followed_events
    get :show_followed_venues
    get '/:id', action: :show
  end

  resources :artists, only: %i[show create update]
  resources :producers, only: %i[show create update]
  resources :venues, only: %i[show create update]

  namespace :admin do
    resources :artists, only: %i[index show create update destroy] do
      collection do
        get :search_typeahead
      end
    end
    resources :producers, only: %i[index show create update destroy] do
      collection do
        get :search_typeahead
      end
    end
    resources :venues, only: %i[index show create update destroy] do
      collection do
        get :search_typeahead
      end
    end
    resources :users, only: %i[index show create update destroy] do
      member do
        put :restore
        put :block
        put :unblock
      end
    end

    resources :genres, only: %i[index create update destroy] do
      collection do
        get :genres_select
      end
    end

    resources :roles, only: %i[index show create update destroy] do
      collection do
        get :roles_select
        get :permissions_select
      end
    end

    resources :trust_levels, only: %i[index show create update destroy]
    resources :penalty_thresholds, only: %i[index create update destroy]
    resources :events, only: %i[index show create update destroy]

    constraints(id: /[^\/]+/) do
      resources :backups, only: %i[index destroy create] do
        member do
          post :restore_backup
        end
      end
    end

    resource :metrics, only: %i[] do
      get :index
      get :metrics_and_user_type
    end
  end

  resources :reviews, only: %i[update destroy] do
    member do
      post :report
    end
  end

  resources :events, only: %i[show create update] do
    post 'add_review/:reviewable_klass', to: 'reviews#create'
    post :add_comment, to: 'comments#create'
    get :comments, to: 'comments#index'
    collection do
      get :search
      get :search_typeahead
      get :discover
    end
    member do
      post :follow
      post :unfollow
      post '/videos/add_video', to: 'videos#create'
      get '/videos', to: 'videos#show'
      get :reviews
      post :report
    end
  end

  resources :videos, only: %i[destroy] do
    member do
      post :report
      post :like
      post :remove_like
    end
  end

  resources :comments, only: %i[update destroy] do
    member do
      post :report
      post :like
      post :remove_like
    end
  end

  resources :artists, only: %i[] do
    member do
      post :follow
      post :unfollow
      get :reviews
      post :report
    end
  end

  resources :venues, only: %i[] do
    member do
      post :follow
      post :unfollow
      get :reviews
      post :report
    end
  end

  resources :producers, only: %i[] do
    member do
      post :follow
      post :unfollow
      get :reviews
      post :report
    end
  end

  resources :reports, only: %i[index show] do
    member do
      post :resolve
    end
  end

  resources :profiles, only: %i[] do
    collection do
      get :search
      get :search_artists
      get :search_producers
      get :search_venues
    end
  end

  resources :versions, only: %i[] do
    member do
      post :report
    end
  end

  get '/check_policy', to: 'policies#check_policy', as: :check_policy
  get '/navigation_policy', to: 'policies#navigation_policy', as: :navigation_policy
end
