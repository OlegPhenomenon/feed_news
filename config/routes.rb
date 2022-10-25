Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root 'feeds#index'
  get 'feeds/:id/authors_publications', to: 'feeds#authors_publications', as: :authors_publications

  resources :posts, except: [:index]
  resources :pins, only: %i[create destroy] do
    member do
      patch :up_to
      patch :down_to
    end
  end
  resources :youtube, only: :show
end
