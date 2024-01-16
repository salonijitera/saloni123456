require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Routes from the new code
  post '/api/users/reset-password', to: 'api/users#reset_password'

  # Routes from the existing code
  put '/api/users/profile', to: 'users#update_profile'
  post '/api/users/verify-email', to: 'api/users#verify_email'
  post '/api/users/register', to: 'api/users#register'
end
