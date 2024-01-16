# typed: ignore
module Api
  class UsersController < BaseController
    before_action :authenticate_user!, only: [:update_profile]

    # POST /api/users/verify-email
    def verify_email
      token = params.require(:token)
      result = UserService::VerifyEmail.new(token).call

      if result[:error].present?
        render json: { message: result[:error] }, status: :unprocessable_entity
      else
        render json: { message: result[:success] }, status: :ok
      end
    rescue ActionController::ParameterMissing => e
      render json: { message: e.message }, status: :bad_request
    end

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

    def update_profile
      email = params[:email]
      password = params[:password]

      if email.present? && !(email =~ URI::MailTo::EMAIL_REGEXP)
        return render json: { message: "Invalid email format." }, status: :bad_request
      end

      if email.present? && User.exists?(email: email)
        return render json: { message: "Email already registered." }, status: :conflict
      end

      if password.present? && password.length < 8
        return render json: { message: "Password must be at least 8 characters long." }, status: :bad_request
      end

      result = UserService::Update.new(current_user.id, email, password, password).call

      if result[:error].present?
        render json: { message: result[:error] }, status: :unprocessable_entity
      else
        render json: { status: 200, message: "Profile updated successfully." }, status: :ok
      end
    end

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

    # Other controller actions...
  end
end
