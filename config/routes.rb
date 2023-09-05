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

  resource :users, controller: 'users/users', only: [] do
    get :user_info
  end

  resources :followers, only: [] do
    collection do
      post 'follow_venue', to: 'followers#follow_venue'
      # get 'follow_venue/:id', to: 'followers#follow_venue_show'
      delete 'follow_venue/:id', to: 'followers#unfollow_venue'

      post 'follow_producer', to: 'followers#follow_producer'
      # get 'follow_producer/:id', to: 'followers#follow_producer_show'
      delete 'follow_producer/:id', to: 'followers#unfollow_producer'

      post 'follow_artist', to: 'followers#follow_artist'
      # get 'follow_artist/:id', to: 'followers#follow_artist_show'
      delete 'follow_artist/:id', to: 'followers#unfollow_artist'
    end
  end

  namespace :admin do
    resources :artists, only: %i[index show create update destroy]
    resources :producers, only: %i[index show create update destroy]
    resources :venues, only: %i[index show create update destroy]
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
  end
end