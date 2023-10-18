class UserStat < ApplicationRecord
  has_paper_trail only: [:last_day_visited]
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
end