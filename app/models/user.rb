class User < ApplicationRecord
  acts_as_paranoid
  devise :database_authenticatable,
         :validatable,
         :registerable,
         :recoverable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist

  attr_writer :login

  def login
    @login || username || email
  end

  # Overrides the devise method find_for_authentication
  # Allow users to Sign In using their username or email address
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value', { :value => login.downcase }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable, dependent: :destroy
  accepts_nested_attributes_for :links, allow_destroy: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :username, presence: true, uniqueness: { conditions: -> { with_deleted } }
  validates :full_name, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def state
    return :deleted if deleted?
    return :blocked if blocked?

    :active
  end

  def blocked?
    blocked_until.present?
  end
end
