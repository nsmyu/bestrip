Rails.application.routes.draw do
  root 'home#index'
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

  resources :itineraries do
    member do
      get    'new_member',    to: 'itinerary_users#new_member'
      get    'search_user',   to: 'itinerary_users#search_user'
      patch  'add_member',    to: 'itinerary_users#add_member'
      delete 'remove_member', to: 'itinerary_users#remove_member'
      get    'search_place',  to: 'itineraries#search_place'
      get    'place',         to: 'itineraries#show_place'
    end

    resources :schedules do
      get 'new_with_place', on: :collection
      get 'add_place_to_schedule', on: :collection
    end
  end
end
