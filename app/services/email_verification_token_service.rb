class EmailVerificationTokenService < BaseService
  require 'securerandom'

  def generate_token(user:)
    begin
      token = SecureRandom.hex(10)
      expires_at = 24.hours.from_now

      email_verification_token = EmailVerificationToken.create!(
        token: token,
        expires_at: expires_at,
        user_id: user.id,
        is_used: false
      )

      return token
    rescue => e
      return { error: e.message }
    end
  end
end
