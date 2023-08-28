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
    resources :users, only: %i[index show create update destroy]
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
