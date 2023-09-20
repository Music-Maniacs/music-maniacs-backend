class Comment < ApplicationRecord
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
