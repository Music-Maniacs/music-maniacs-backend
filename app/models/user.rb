class User < ApplicationRecord
  acts_as_paranoid
  ##############################################################################
  # DEVISE CONFIGURATION
  ##############################################################################
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
  # CALLBACKS
  ##############################################################################
  after_initialize :set_default_role

  def set_default_role
    self.role = TrustLevel.default_trust_level if role.blank?
  end

  ##############################################################################
  # SCOPES
  ##############################################################################
  scope :deleted, -> { with_deleted.where.not(deleted_at: nil) }
  scope :blocked, -> { where.not(blocked_until: nil) }
  scope :active, -> { where(deleted_at: nil, blocked_until: nil) }

  scope :search_by_state, lambda { |state|
    case state
    when 'deleted' then deleted
    when 'blocked' then blocked
    when 'active' then active
    end
  }

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true
  belongs_to :role

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

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[username email full_name]
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[search_by_state]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
