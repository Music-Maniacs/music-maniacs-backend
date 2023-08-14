class User < ApplicationRecord
  devise :database_authenticatable,
         :validatable,
         :registerable,
         :recoverable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist
end
