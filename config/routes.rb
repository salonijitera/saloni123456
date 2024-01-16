require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Routes from both new and existing code
  post '/api/users/login', to: 'api/users#login'
  post '/api/users/verify-email', to: 'api/users#verify_email'
  post '/api/users/register', to: 'api/users#register'

  # ... other routes ...
end
