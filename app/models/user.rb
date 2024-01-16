class User < ApplicationRecord
  has_one :email_verification_token, dependent: :destroy

  # validations

  # end for validations

  class << self
    def mark_email_as_verified!(user_id)
      user = find(user_id)
      user.update!(is_email_verified: true)
    end
  end
end
