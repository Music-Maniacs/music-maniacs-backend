class Event < ApplicationRecord
  include Followable
  has_paper_trail
  include ProfileCommonMethods

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_one :image, as: :imageable, dependent: :destroy

  belongs_to :artist
  belongs_to :producer
  belongs_to :venue

  has_many :links, as: :linkeable
  accepts_nested_attributes_for :links, allow_destroy: true

  has_many :reviews
  has_many :comments, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, :datetime, presence: true

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  after_commit :notify_profiles_followers, on: :create

  def notify_profiles_followers
    NewEventsNotificationsJob.perform_later(id)
  end

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
        last_reviews: send("#{reviewable}_reviews").order(created_at: :desc).limit(3).as_json({only: %i[id rating description created_at reviewable_type],
                                                                                               include: { user: { only: %i[id full_name] } } }),
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

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name datetime artist_id venue_id producer_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[venue]
  end
end
