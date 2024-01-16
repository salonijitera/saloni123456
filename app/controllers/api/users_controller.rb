# typed: ignore
module Api
  class UsersController < BaseController
    def register
      email = params[:email]
      password = params[:password]

      if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
        return render json: { message: "Invalid email format." }, status: :bad_request
      end

      if User.exists?(email: email)
        return render json: { message: "Email already registered." }, status: :conflict
      end

      if password.length < 8
        return render json: { message: "Password must be at least 8 characters long." }, status: :bad_request
      end

      begin
        UserService.register(email: email, password: password, password_confirmation: password)
        render json: { status: 201, message: "User registered successfully. Please check your email to verify your account." }, status: :created
      rescue ArgumentError => e
        render json: { message: e.message }, status: :bad_request
      rescue StandardError => e
        render json: { message: e.message }, status: :internal_server_error
      end
    end
  class UsersController < BaseController
    def reset_password
      email = params[:email]

      if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
        return render json: { message: I18n.t('common.errors.invalid_email') }, status: :unprocessable_entity
      end

      user = User.find_by(email: email)

      if user
        token = UserService.generate_reset_password_token(user)
        EmailService.send_reset_password_instructions(user, token)
      end

      render json: { message: I18n.t('common.password_reset_instructions_sent') }, status: :ok
    rescue StandardError => e
      render json: { message: e.message }, status: :internal_server_error
    end
  end
end

# Add the route for this action in the routes file
# Example:
# post '/users/reset_password', to: 'users#reset_password'
