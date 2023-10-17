Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
               passwords: 'users/passwords'
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

  constraints(id: /[^\/]+/) do
    resources :backups, only: %i[index destroy create] do
      member do
        post :restore_backup
      end
    end
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
  end

  resources :reviews, only: %i[update destroy]

  resources :events, only: %i[show create update] do
    post 'add_review/:reviewable_klass', to: 'reviews#create'
    post :add_comment, to: 'comments#create'
    get :comments, to: 'comments#index'
    collection do
      get :search
      get :discover
    end
    member do
      post :follow
      post :unfollow
      post '/videos/add_video', to: 'videos#create'
      get '/videos', to: 'videos#show'
      get :reviews
    end
  end

  resources :videos, only: %i[destroy] do
    member do
      post :like
      post :remove_like
    end
  end

  resources :comments, only: %i[update destroy] do
    member do
      post :like
      post :remove_like
    end
  end

  resources :artists, only: %i[] do
    member do
      post :follow
      post :unfollow
      get :reviews
    end
  end

  resources :venues, only: %i[] do
    member do
      post :follow
      post :unfollow
      get :reviews
    end
  end

  resources :producers, only: %i[] do
    member do
      post :follow
      post :unfollow
      get :reviews
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

  resource :metrics, only: %i[] do
    get :show_metrics
    get :show_type_users
    get :show_comments
    get :show_reviews
    # get :show_reports
  end
end
