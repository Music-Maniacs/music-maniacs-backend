class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :user

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :user_id, uniqueness: { scope: :followable_id }
end