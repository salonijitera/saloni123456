# frozen_string_literal: true

class TokenService
  # Generates a token for a given user
  def self.generate_token(user)
    # Assuming CustomAccessToken is a model that handles token creation
    token = CustomAccessToken.create!(
      user: user,
      expires_at: Time.current + 2.hours # Set expiration time as needed
    )

    token.token # Return the generated token
  end
end
