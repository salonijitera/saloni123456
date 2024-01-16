class User < ApplicationRecord
  has_one :email_verification_token, dependent: :destroy

  # validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, if: -> { new_record? || password.present? }
  validates :password_confirmation, presence: true, if: -> { new_record? || password.present? }

  has_secure_password
  # end for validations

  # Additional attribute for email verification
  attribute :is_email_verified, :boolean, default: false

  class << self
    def update_user_profile(id, email, password, password_confirmation)
      # Implementation for updating user profile will go here
    end

    def mark_email_as_verified!(user_id)
      user = find(user_id)
      user.update!(is_email_verified: true)
    end
  end
end
