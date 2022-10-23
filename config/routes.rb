Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root 'feeds#index'

  resources :posts, except: [:index]
  resources :pins, only: %i[create destroy] do
    member do
      patch :up_to
      patch :down_to
    end
  end
end
