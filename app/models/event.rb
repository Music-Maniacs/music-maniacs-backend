class Event < ApplicationRecord
  has_paper_trail
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
  has_many :artists_reviews, through: :reviews, source: :reviewable, source_type: 'Artist'
  has_many :producers_reviews, through: :reviews, source: :reviewable, source_type: 'Producer'
  has_many :venues_reviews, through: :reviews, source: :reviewable, source_type: 'Venue'
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, :datetime, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def rating
    reviews.average(:rating) || 0
  end

  %w[artist producer venue].each do |reviewable|
    define_method "#{reviewable}_rating" do
      reviews.where(reviewable_type: reviewable.capitalize).average(:rating) || 0
    end
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name datetime artist_id venue_id producer_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
