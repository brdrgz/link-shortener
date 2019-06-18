Rails.application.routes.draw do
  root to: 'short_links#new'

  resources :short_links, only: [:new, :create, :show, :update]
  get 's/:short_url', to: 'short_links#index', as: 'shortened'
  get 'e/:admin_url', to: 'short_links#edit', as: 'admin'

  match '*path', to: 'short_links#new', via: :all
end
