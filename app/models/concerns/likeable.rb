module Likeable
  extend ActiveSupport::Concern

  included do
    attr_accessor :liked_by_current_user

    has_many :likes, as: :likeable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user
  end

  class_methods do
    def with_liked_by_user(user)
      all.each do |comment|
        comment.liked_by_current_user = user.likes?(comment)
      end
    end
  end

  def add_like(user)
    liking_users << user
  end

  def remove_like(user)
    liking_users.delete(user)
  end

  def likes_count
    likes.count
  end
end
