module Reviewable
  extend ActiveSupport::Concern

  included do
    has_many :reviews, as: :reviewable, dependent: :destroy
  end

  def rating
    reviews.average(:rating).to_f || 0
  end

  def reviews_count
    reviews.count
  end

  def reviews_last
    reviews.order(updated_at: :desc).limit(5)
  end
end
