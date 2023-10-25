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

  resources :users do
    get 'places/index_lazy', to: 'places#index_lazy'
    resources :places

  end

  resources :itineraries do
    member do
      resources :itinerary_users, only: [:new, :create, :destroy]
      get 'search_user', to: 'itinerary_users#search_user'
      get 'find_destinations', to: 'places#find_destinations'
    end

    resources :schedules
    get 'destinations/index_lazy', to: 'destinations#index_lazy'
    get 'destinations/select_itinerary', on: :collection
    resources :destinations, only: [:index, :new, :create, :show, :destroy]
    resources :places
  end

  resources :posts
  get 'favorites/index_lazy', to: 'favorites#index_lazy'
  resources :favorites, only: [:index, :new, :create, :show, :destroy]
  get 'find_places', to: 'places#find_places'
end
