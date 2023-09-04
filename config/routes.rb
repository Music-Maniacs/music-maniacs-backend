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

  namespace :admin do
    resources :artists, only: %i[index show create update destroy]
    resources :producers, only: %i[index show create update destroy]
    resources :venues, only: %i[index show create update destroy]

    resources :followers, only: [] do
      collection do
        post 'follow_user', to: 'followers#follow_user'
        # get 'follow_user/:user_id', to: 'followers#follow_user_show'
        # delete 'follow_user/:user_id', to: 'followers#unfollow_user'

        # post 'follow_event', to: 'followers#follow_event'
        # get 'follow_event/:event_id', to: 'followers#follow_event_show'
        # delete 'follow_event/:event_id', to: 'followers#follow_event_destroy'

        post 'follow_venue', to: 'followers#follow_venue'
        # get 'follow_venue/:venue_id', to: 'followers#follow_venue_show'
        # delete 'follow_venue/:venue_id', to: 'followers#follow_venue_destroy'

        # post 'follow_producer', to: 'followers#follow_producer_create'
        # get 'follow_producer/:producer_id', to: 'followers#follow_producer_show'
        # delete 'follow_producer/:producer_id', to: 'followers#follow_producer_destroy'
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
  end
end