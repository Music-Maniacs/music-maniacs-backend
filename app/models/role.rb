class Role < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_and_belongs_to_many :permissions
  has_many :users, dependent: :restrict_with_error

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
