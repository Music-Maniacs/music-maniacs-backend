class Permission < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_and_belongs_to_many :roles

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :action, :subject_class, presence: true
end
