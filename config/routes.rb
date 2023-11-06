Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  devise_scope :user do
    get   'users/guest_sign_in',  to: 'users/sessions#guest_sign_in'
    get   'users/edit_email',     to: 'users/registrations#edit_email'
    get   'users/edit_profile',   to: 'users/registrations#edit_profile'
    patch 'users/update_without_password', to: 'users/registrations#update_without_password'
    patch 'users/validate_bestrip_id', to: 'users/registrations#validate_bestrip_id'
  end

  concern :placeable do
    get 'places/index_lazy', to: 'places#index_lazy'
    get 'places/find',       to: 'places#find'
    resources :places, only: %i(index new create show destroy)
  end

  namespace :users do
    concerns :placeable
  end
  resources :users, only: :show

  resources :itineraries do
    resources :schedules

    member do
      resources :itinerary_users, only: %i(new create destroy)
      get 'search_user', to: 'itinerary_users#search_user'
    end

    scope module: :itineraries do
      get  'places/select_itinerary',     to: 'places#select_itinerary', on: :collection
      post 'places/add_from_user_places', to: 'places#add_from_user_places'
      concerns :placeable
    end
  end

  resources :posts do
    get 'search', to: 'posts#search', on: :collection
  end

end
