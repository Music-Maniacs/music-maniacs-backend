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
    resources :users, only: %i[index show create update destroy]
  end
end
