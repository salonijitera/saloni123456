class UserService
  require 'securerandom'

  def self.generate_reset_password_token(email)
    user = User.find_by(email: email)

    return nil unless user

    token = SecureRandom.hex(10)
    expiration_time = 2.hours.from_now

    email_verification_token = user.email_verification_token || user.build_email_verification_token
    email_verification_token.assign_attributes(token: token, expires_at: expiration_time, is_used: false)
    email_verification_token.save!

    # TODO: Send an email to the user with the password reset token and instructions on how to reset their password.
    # This is a placeholder for the email sending logic.
    # MailerService.send_password_reset_email(user.email, token)

    "If your email is associated with an account, instructions to reset your password have been sent."
  rescue ActiveRecord::RecordInvalid => e
    # Log the error
    Rails.logger.error("UserService::generate_reset_password_token - #{e.message}")
    nil
  end
end

# Note: The MailerService is a placeholder and should be replaced with the actual mailer service used in the project.
# The actual implementation of sending the email should handle exceptions and ensure that the email is sent successfully.
