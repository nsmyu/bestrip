Rails.application.routes.draw do
  root 'home#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  devise_scope :user do
    get "guest_sign_in", to: 'users/sessions#guest_sign_in'
  end
end
