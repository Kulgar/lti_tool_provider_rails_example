# This model is used to keep an historics of received nonces from the application
# According to "Canvas" from instructure, 90 minutes is a good window
class OauthNonce < ActiveRecord::Base
  
  # Check if the oauth_nonce parameter is recent enough
  def nonce_valid?
    existing_nonces = OauthNonce.where("nonce = ? AND updated_at >= ?", nonce, (Time.now - 90.minutes))
    if existing_nonces.any?
      errors.add(:nonce, "can't be reused so soon")
      return false
    end
    return true
  end
  
  # Create / update nonce if it is a valid one
  def self.create_or_update(nonce)
    oauth_nonce = self.where(:nonce => nonce).first_or_initialize
    if !nonce.blank? && oauth_nonce.nonce_valid?
      oauth_nonce.save
    else
      oauth_nonce.errors.add(:nonce, "can't be blank") if nonce.blank?
    end
    return oauth_nonce
  end
end
