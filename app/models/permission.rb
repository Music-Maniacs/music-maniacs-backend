class Permission < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_and_belongs_to_many :roles

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :name, presence: true
  validates :name, uniqueness: { scope: :subject_class }
  validates :action, :subject_class, presence: true
end
