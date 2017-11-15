Rails.application.routes.draw do
  root 'home#index'
  namespace :ajax do
    post '/verify', to: 'pass_codes#verify', as: :verify_pass_code
    resources :meters, only: :create
    post '/reverse', to: 'meters#reverse', as: :reverse_meter
  end
end
