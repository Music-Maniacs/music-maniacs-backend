class Review < ApplicationRecord
  include Reportable
  include Versionable
  has_paper_trail versions: { class_name: 'Version' }, ignore: %i[id created_at updated_at deleted_at]
  acts_as_paranoid

  TO_JSON = { only: %i[id rating description created_at reviewable_type],
              include: { user: { only: %i[id full_name], methods: :profile_image_full_url } },
              methods: %i[anonymous reviewable_name] }.freeze
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

  def reviewable_name
    reviewable.name
  end

  def author_id
    user_id
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
