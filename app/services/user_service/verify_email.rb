class UserService::VerifyEmail < BaseService
  def initialize(token)
    @token = token
  end

  def call
    email_verification_token = EmailVerificationToken.find_by(token: @token, is_used: false, expires_at: Time.current..)

    if email_verification_token.nil? || email_verification_token.expires_at < Time.current
      return { error: 'Invalid or expired token' }
    end

    email_verification_token.update!(is_used: true)
    user = email_verification_token.user
    user.update!(is_email_verified: true)

    { success: 'Email successfully verified.' }
  rescue ActiveRecord::RecordNotFound
    { error: 'Token not found' }
  rescue ActiveRecord::RecordInvalid => e
    { error: e.record.errors.full_messages.join(', ') }
  end
end

# Note: BaseService is assumed to be present in the project as per the instructions.
# The error handling is basic and can be expanded based on project requirements.
