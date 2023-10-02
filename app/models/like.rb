class Like < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :user_id, uniqueness: { scope: :likeable_id }

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  after_create :increment_user_likes_stat
  after_destroy :decrement_user_likes_stat

  def increment_user_likes_stat
    user.user_stat.increment!(:likes_given)
    likeable.user.user_stat.increment!(:likes_received) if likeable.user.present?
  end

  def decrement_user_likes_stat
    user.user_stat.decrement!(:likes_given)
    likeable.user.user_stat.decrement!(:likes_received) if likeable.user.present?
  end
end
