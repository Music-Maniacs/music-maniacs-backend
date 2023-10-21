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
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value',
                                    { value: login.downcase }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end

  def active_for_authentication?
    super && !blocked?
  end

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  after_create :create_user_stat
  after_initialize :set_default_role

  def set_default_role
    self.role = TrustLevel.default_trust_level if role.blank?
  end

  def create_user_stat
    UserStat.create!(
      user: self,
      days_visited: 0,
      viewed_events: 0,
      likes_received: 0,
      likes_given: 0,
      comments_count: 0,
      penalty_score: 0
    )
  end

  ##############################################################################
  # SCOPES
  ##############################################################################
  scope :deleted, -> { with_deleted.where.not(deleted_at: nil) }
  scope :blocked, -> { where.not(blocked_until: nil) }
  scope :active, -> { where(deleted_at: nil, blocked_until: nil) }
  scope :regular, -> { joins(:role).where(role: { type: 'TrustLevel' }) }

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
  has_many :comments
  has_many :reviews
  has_many :follows, dependent: :destroy
  has_many :followed_artists, through: :follows, source: :followable, source_type: 'Artist'
  has_many :followed_venues, through: :follows, source: :followable, source_type: 'Venue'
  has_many :followed_producers, through: :follows, source: :followable, source_type: 'Producer'
  has_many :followed_events, through: :follows, source: :followable, source_type: 'Event'
  has_one :profile_image, -> { where("image_type = ?", 'profile') }, class_name: 'Image', as: :imageable, dependent: :destroy
  has_one :cover_image, -> { where("image_type = ?", 'cover') }, class_name: 'Image', as: :imageable, dependent: :destroy
  has_one :user_stat
  has_many :likes, dependent: :destroy
  has_many :videos

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
    blocked_until && blocked_until > Time.zone.now
  end

  def block!(blocked_until)
    update!(blocked_until:)
  end

  def unblock!
    update!(blocked_until: nil)
  end

  def follows?(entity)
    follows.exists?(followable: entity)
  end

  def likes?(entity)
    likes.exists?(likeable: entity)
  end

  def last_reviews
    reviews.order(created_at: :desc).limit(5)
  end

  def update_trust_level!
    raise StandardError, 'user does not have trust level' unless role.is_a?(TrustLevel)

    trust_levels = TrustLevel.all.order(order: :desc)
    trust_levels.each do |trust_level|
      if trust_level.requirements_met_by_user?(self) && role.order != trust_level.order
        update!(role: trust_level)
        break
      end
    end
  end

  def increment_penalization_score!(score)
    user_stat.increment!(:penalty_score, score)
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.update_trust_levels
    trust_levels = TrustLevel.all.order(order: :desc)
    regular.find_each do |user|
      trust_levels.each do |trust_level|
        if trust_level.requirements_met_by_user?(user) && user.role.order != trust_level.order
          user.update!(role: trust_level)
          break
        end
      end
    rescue StandardError => e
      puts e
      next
    end
  end

  def self.permanent_block_years
    100
  end

  def self.permanent_block_date_from_now
    Date.today + permanent_block_years.years
  end

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
