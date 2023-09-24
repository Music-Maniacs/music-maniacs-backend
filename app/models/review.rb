class Review < ApplicationRecord
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validate :one_review_per_user_per_reviewable, on: :create

  def one_review_per_user_per_reviewable
    return unless Review.where(user_id:, event_id:, reviewable_id:, reviewable_type:).exists?

    errors.add(:base, :already_reviewed)
  end

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :user
  belongs_to :reviewable, polymorphic: true
  belongs_to :event

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def anonymous?
    user.nil?
  end
  alias anonymous anonymous?

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
