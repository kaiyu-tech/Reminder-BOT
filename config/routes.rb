require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD']))
  end
  mount Sidekiq::Web => '/sidekiq'

  root 'sessions#new'

  post '/callback' => 'linebot#callback'
  get '/notify' => 'linebot#notify'

  get '/help' => 'static_pages#help'
  get '/about' => 'static_pages#about'

  get '/destroy/sessions' => 'sessions#destroy'

  resources :sessions, only: [:new, :create]
  resources :users, only: [:index, :edit, :update, :destroy]
  resources :events, only: [:index, :new, :create, :edit, :update, :destroy]
end