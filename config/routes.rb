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
      get 'new_member', to: 'itineraries#new_member'
      get 'search_user', to: 'itineraries#search_user'
      get 'add_user', to: 'itineraries#add_user'
    end
  end
end
