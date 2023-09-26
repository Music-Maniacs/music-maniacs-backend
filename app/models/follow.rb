class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :user

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :user_id, uniqueness: { scope: :followable_id }

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def followable_name
    case followable_type
    when 'Artist'
      Artist.find_by(id: followable_id)&.name
    when 'Producer'
      Producer.find_by(id: followable_id)&.name
    when 'Venue'
      Venue.find_by(id: followable_id)&.name
    when 'Event'
      Event.find_by(id: followable_id)&.name
    end
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.ransackable_attributes(_auth_object = nil)
    %w[followable_type]
  end
end