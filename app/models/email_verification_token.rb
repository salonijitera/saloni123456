class EmailVerificationToken < ApplicationRecord
  belongs_to :user

  # validations

  # end for validations

  class << self
  end
end
