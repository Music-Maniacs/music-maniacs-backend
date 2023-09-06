class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :followable_id }
end
