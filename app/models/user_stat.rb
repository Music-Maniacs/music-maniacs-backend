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

  def modify_counter(counter, increment)
    return unless self

    case counter
    when :viewed_events
      self.viewed_events += increment
    when :likes_received
      self.likes_received += increment
    when :likes_given
      self.likes_given += increment
    when :comments_count
      self.comments_count += increment
    when :penalty_score
      self.comments_count += increment
    end
    save
  end

  def increase_counter(counter)
    modify_counter(counter, 1)
  end

  def decrease_counter(counter)
    modify_counter(counter, -1)
  end

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