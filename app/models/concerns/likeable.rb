module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likeable, dependent: :destroy
    has_many :liking_users, through: :likes, source: :user
  end

  def add_like(user)
    liking_users << user
  end

  def remove_like(user)
    liking_users.delete(user)
  end
end
