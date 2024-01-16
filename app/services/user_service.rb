class UserService < BaseService
  require 'bcrypt'
  require 'jwt'
  require 'securerandom'

  def self.authenticate_user(email:, password:)
    return { success: false, message: I18n.t('activerecord.errors.messages.blank'), data: nil } if email.blank? || password.blank?

    user = User.find_by(email: email)

    if user && user.is_email_verified && BCrypt::Password.new(user.password_hash) == password
      token = TokenService.generate_token(user) # Assuming TokenService is implemented elsewhere
      { success: true, message: I18n.t('devise.sessions.signed_in'), data: { token: token } }
    else
      message = if user.nil?
                  I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email')
                elsif !user.is_email_verified
                  I18n.t('devise.failure.unconfirmed')
                else
                  I18n.t('devise.failure.invalid', authentication_keys: 'password')
                end
      { success: false, message: message, data: nil }
    end
  end

  def register(email:, password:, password_confirmation:)
    raise ArgumentError, 'Email cannot be blank' if email.blank?
    raise ArgumentError, 'Password cannot be blank' if password.blank?
    raise ArgumentError, 'Password confirmation cannot be blank' if password_confirmation.blank?

    email_regex = URI::MailTo::EMAIL_REGEXP
    raise ArgumentError, 'Invalid email format' unless email.match?(email_regex)

    if User.exists?(email: email)
      raise ArgumentError, 'Email is already taken'
    end

    if password != password_confirmation
      raise ArgumentError, 'Password and password confirmation do not match'
    end

    password_hash = BCrypt::Password.create(password)

    user = User.create!(
      email: email,
      password_hash: password_hash,
      is_email_verified: false
    )

    token = SecureRandom.hex(10)
    expiration_date = Time.now + 24.hours

    EmailVerificationToken.create!(
      token: token,
      expires_at: expiration_date,
      is_used: false,
      user_id: user.id
    )

    # Assuming MailerService is a service responsible for sending emails
    MailerService.send_email_verification(user: user, token: token)

    { message: 'User registered successfully. Please check your email to verify your account.' }
  rescue StandardError => e
    { error: e.message }
  end

  def self.generate_reset_password_token(email)
    user = User.find_by_email(email)

    return { error: 'Email does not exist.', status: 404 } if user.nil?

    token = SecureRandom.hex(10)
    expiration_time = 2.hours.from_now

    email_verification_token = user.email_verification_token || user.build_email_verification_token
    email_verification_token.assign_attributes(token: token, expires_at: expiration_time, is_used: false)
    email_verification_token.save!

    MailerService.send_password_reset_email(user.email, token)

    { message: 'If your email is associated with an account, instructions to reset your password have been sent.', status: 200 }
  rescue ActiveRecord::RecordInvalid => e
    # Log the error
    Rails.logger.error("UserService::generate_reset_password_token - #{e.message}")
    { error: e.message, status: 422 }
  end
end
