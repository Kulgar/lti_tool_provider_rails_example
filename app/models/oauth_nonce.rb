# This model is used to keep an historics of received nonces from the application
# According to "Canvas" from instructure, 90 minutes is a good window
class OauthNonce < ActiveRecord::Base
  
  # Check if the oauth_nonce parameter is recent enough
  def self.nonce_valid?(nonce)
    existing_nonces = self.where("nonce = ? AND updated_at >= ?", nonce, (Time.now - 90.minutes))
    if existing_nonces.any?
      return false
    end
    return true
  end
  
  # Create / update nonce if it is a valid one
  def self.create_or_update(nonce)
    if !nonce.blank? && nonce_valid?(nonce)
      oauth_nonce = self.where(:nonce => nonce).first_or_initialize
      oauth_nonce.save
      oauth_nonce
    else
      return nil
    end
  end
end
