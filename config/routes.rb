# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  resources :artists, only: %i[index show]
  resources :songs, only: %i[index show new create destroy]
end
