class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :remember_token

  before_save { self.email.downcase! }
  has_secure_password

  validates :email, presence: true, length: { maximum: 255 },
    uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL_REGEX }
  validates :name, presence: true, length: { maximum: 50 }
  validates :password, presence: true, length: { minimum: 6 }

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine::cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

end
