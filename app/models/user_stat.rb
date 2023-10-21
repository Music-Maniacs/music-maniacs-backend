class UserStat < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :user

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :days_visited, :viewed_events, :likes_received,
            :likes_given, :comments_count, :penalty_score, presence: true

  def increment_days_visited_once_per_day
    if last_day_visited.nil? || last_day_visited < Time.current.beginning_of_day
      self.days_visited += 1
      self.last_session = Time.current
      self.last_day_visited = Time.current
    else
      self.last_session = last_day_visited
    end
    save
  end

  ##############################################################################
  # CALLBACKS
  ##############################################################################
  after_update :check_penalty_thresholds, if: :saved_change_to_penalty_score?

  def check_penalty_thresholds
    thresholds = PenaltyThreshold.all
    thresholds_scores = thresholds.map(&:penalty_score)
    old_threshold = thresholds_scores.select { |score| penalty_score_previously_was >= score }.max
    new_threshold = thresholds_scores.select { |score| penalty_score >= score }.max

    return unless old_threshold != new_threshold

    threshold_block_days = thresholds.find_by(penalty_score: new_threshold).days_blocked
    user.increment_block_date_by_days!(threshold_block_days)
  end

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def increment_penalization_score!(score)
    update(penalty_score: penalty_score + score)
  end
end
