require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # New route from the new code
  post '/api/users/verify-email', to: 'api/users#verify_email'
  
  # Existing route from the existing code
  post '/api/users/register', to: 'api/users#register'
end
