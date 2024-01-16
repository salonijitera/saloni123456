module UserService
  class Update < BaseService
    attr_reader :user_id, :email, :password, :password_confirmation

    def initialize(user_id, email, password, password_confirmation)
      @user_id = user_id
      @email = email
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      user = User.find_by(id: user_id)
      return { error: 'User not found' } unless user

      if email.present?
        return { error: 'Invalid email format' } unless email =~ URI::MailTo::EMAIL_REGEXP
        return { error: 'Email has already been taken' } if User.exists?(email: email)
      end

      if password.present?
        return { error: 'Password confirmation does not match' } unless password == password_confirmation
        user.password_hash = User.digest(password)
      end

      user.email = email if email.present?

      if user.save
        { success: 'User profile has been updated' }
      else
        { error: user.errors.full_messages.join(', ') }
      end
    rescue StandardError => e
      { error: e.message }
    end
  end
end

# Add this line to user.rb if has_secure_password is not implemented
# has_secure_password
