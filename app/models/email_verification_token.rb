
class EmailVerificationToken < ApplicationRecord
  belongs_to :user

  # validations

  scope :valid_tokens, -> { where('expires_at > ? AND is_used = ?', Time.current, false) }

  def mark_as_used!
    update(is_used: true)
  end

  # end for validations

  class << self
  end
end
