class Review < ApplicationRecord
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validate :one_review_per_user_per_reviewable

  def one_review_per_user_per_reviewable
    return unless Review.where(user_id:, reviewable_id:, reviewable_type:).exists?

    errors.add(:base, :already_reviewed)
  end

  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :user
  belongs_to :reviewable, polymorphic: true
  belongs_to :event

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
