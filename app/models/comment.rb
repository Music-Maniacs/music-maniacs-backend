class Comment < ApplicationRecord
  include Reportable
  include Likeable
  acts_as_paranoid
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :user
  belongs_to :event

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :body, presence: true

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  after_create :increment_count_comments
  after_destroy :decrement_count_comments

  def increment_count_comments
    user.user_stat.increment!(:comments_count)
  end

  def decrement_count_comments
    user.user_stat.decrement!(:comments_count)
  end

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
end
