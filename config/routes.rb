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

  resource :users, only: [] do
    get '/user_info', to: 'users/users#user_info'
    put '/current', to: 'users/users#update'
    put '/current/change_password', to: 'users/users#change_password'
    delete '/current', to: 'users/users#destroy'
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
    end
    member do
      post :follow
      post :unfollow
      get :reviews
    end
  end

  resources :comments, only: %i[update destroy]

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
end
