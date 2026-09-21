# frozen_string_literal: true

SmsTrap::Engine.routes.draw do
  root to: 'conversations#index'
  resources :conversations, only: %i[index show] do
    resource :reply, only: :create
  end
end
