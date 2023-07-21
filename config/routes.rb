Rails.application.routes.draw do
  root 'home#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  devise_scope :user do
    get "users/guest_sign_in", to: 'users/sessions#guest_sign_in'
    get 'users/edit_password', to: 'users/registrations#edit'
    get 'users/edit_email', to: 'users/registrations#edit_email'
    get 'users/profile', to: 'users/registrations#profile'
    get 'users/profile/edit', to: 'users/registrations#profile_edit'
  end
end
