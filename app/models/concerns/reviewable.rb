module Reviewable
  extend ActiveSupport::Concern

  included do
    has_many :reviews, as: :reviewable, dependent: :destroy
  end

  def rating
    reviews.average(:rating) || 0
  end

  def reviews_count
    reviews.count
  end
end
