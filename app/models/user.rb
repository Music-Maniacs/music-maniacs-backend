class User < ApplicationRecord
  devise :database_authenticatable,
         :validatable,
         :registerable,
         :recoverable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :email, :username, presence: true, uniqueness: true
  validates :full_name, presence: true
end
