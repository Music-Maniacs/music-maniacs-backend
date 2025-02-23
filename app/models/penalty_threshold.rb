class PenaltyThreshold < ApplicationRecord
  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :penalty_score, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :days_blocked, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def permanent_block
    days_blocked == self.class.permanent_block_days
  end

  ##############################################################################
  # CLASS METHODS
  ##############################################################################
  def self.permanent_block_days
    100 * 365 # 100 años, lo que pusismos en la documentacion
  end
end
