Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  devise_scope :user do
    get   'users/guest_sign_in',  to: 'users/sessions#guest_sign_in'
    get   'users/edit_password',  to: 'users/registrations#edit'
    get   'users/edit_email',     to: 'users/registrations#edit_email'
    get   'users/profile',        to: 'users/registrations#profile'
    get   'users/edit_profile',   to: 'users/registrations#edit_profile'
    patch 'users/update_without_password', to: 'users/registrations#update_without_password'
    patch 'users/validate_bestrip_id', to: 'users/registrations#validate_bestrip_id'
  end

  namespace :users do
    get 'places/index_lazy', to: 'places#index_lazy'
    get 'places/find', to: 'places#find'
    resources :places, only: %i(index new create show destroy)
  end

  resources :itineraries do
    member do
      resources :itinerary_users, only: %i(new create destroy)
      get 'search_user', to: 'itinerary_users#search_user'
    end

    scope module: :itineraries do
      get 'places/index_lazy', to: 'places#index_lazy'
      get 'places/select_itinerary', to: 'places#select_itinerary', on: :collection
      post 'places/from_user_to_itinerary', to: 'places#from_user_to_itinerary'
      get 'places/find', to: 'places#find'
      resources :places, only: %i(index new create show destroy)
    end

    resources :schedules
  end

  resources :posts
end
