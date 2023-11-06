class Event < ApplicationRecord
  include Followable
  include Reportable

  def self.ignored_version_attrs
    %i[popularity_score views_count]
  end

  include Versionable
  acts_as_paranoid

  NOTIFIABLE_ATTRIBUTES = %i[name datetime artist_id venue_id producer_id].freeze
  VISIT_VALUE = 10.minutes.to_i
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_one :image, as: :imageable

  has_many :videos, dependent: :destroy

  belongs_to :artist, optional: true
  belongs_to :producer, optional: true
  belongs_to :venue, optional: true

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_many :reviews, dependent: :destroy
  has_many :comments, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, :datetime, presence: true

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  after_commit :notify_profiles_followers, on: :create
  after_commit :notify_changes_to_followers, on: :update
  # TODO: after_commit :notify_changes_to_followers, on: :destroy
  before_create :set_popularity_score
  before_update :set_popularity_score, if: :will_save_change_to_views_count?
  before_update :update_reviews, if: proc { |event| event.artist_id_changed? || event.venue_id_changed? || event.producer_id_changed? }

  def update_reviews
    reviews.where(reviewable_type: 'Artist').update_all(reviewable_id: artist_id) if artist_id_changed? && artist_id.present?
    reviews.where(reviewable_type: 'Venue').update_all(reviewable_id: venue_id) if venue_id_changed? && venue_id.present?
    reviews.where(reviewable_type: 'Producer').update_all(reviewable_id: producer_id) if producer_id_changed? && producer_id.present?
  end

  def notify_changes_to_followers
    changes = parsed_previous_changes
    return unless changes.present? || followers.count.zero?

    EventUpdateNotificationsJob.perform_later(id, changes)
  end

  def notify_profiles_followers
    NewEventsNotificationsJob.perform_later(id)
  end

  def set_popularity_score
    self.popularity_score = calculate_popularity_score
  end

  ##############################################################################
  # SCOPES
  ##############################################################################
  scope :most_popular, -> { order(popularity_score: :desc) }
  scope :by_artist, ->(artist_id) { where(artist_id:) }

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def rating
    reviews.average(:rating).to_f || 0
  end

  %w[artist producer venue].each do |reviewable|
    define_method "#{reviewable}_reviews" do
      reviews.where(reviewable_type: reviewable.capitalize)
    end

    define_method "#{reviewable}_rating" do
      send("#{reviewable}_reviews").average(:rating) || 0
    end

    define_method "#{reviewable}_reviews_info" do
      {
        rating: send("#{reviewable}_rating"),
        reviews_count: send("#{reviewable}_reviews").count,
        last_reviews: send("#{reviewable}_reviews").order(created_at: :desc).limit(3).as_json(Review::TO_JSON)
      }
    end
  end

  def reviews_info
    {
      artist: artist_reviews_info,
      producer: producer_reviews_info,
      venue: venue_reviews_info
    }
  end

  def increase_visits_count!
    update!(views_count: views_count + 1)
  end

  def parsed_previous_changes
    changes = previous_changes.to_h.select { |key| NOTIFIABLE_ATTRIBUTES.include?(key.to_sym) }
    %w[artist_id venue_id producer_id].each do |attribute|
      next unless changes[attribute].present?

      klass = attribute.gsub('_id', '').capitalize.constantize
      previous_klass_name = klass.find_by(id: changes[attribute][0])&.name
      new_klass_name = klass.find_by(id: changes[attribute][1])&.name
      changes[attribute] = [previous_klass_name, new_klass_name]
    end
    changes
  end

  def calculate_popularity_score
    created_at.to_i + (views_count || 0) * VISIT_VALUE
  end

  def author_id
    author_id_by_versions
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.discover_by_location(city:, province:, country:)
    events = all.ransack(venue_location_city: city).result(distinct: true)
    if events.size < 10
      events = all.ransack(venue_location_province: province).result(distinct: true)
      if events.size < 10
        events = all.ransack(venue_location_country: country).result(distinct: true)
      end
    end
    events
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name datetime artist_id venue_id producer_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[venue]
  end
end
