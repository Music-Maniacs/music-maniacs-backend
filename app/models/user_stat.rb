class UserStat < ApplicationRecord
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :user

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :days_visited, :viewed_events, :likes_received, :likes_given, :comments_count, presence: true

  def modify_counter(counter, increment)
    return unless user_stat

    case counter
    when :viewed_events
      user_stat.viewed_events += increment
    when :likes_received
      user_stat.likes_received += increment
    when :likes_given
      user_stat.likes_given += increment
    when :comments_count
      user_stat.comments_count += increment
    end
    user_stat.save
  end

  def increase_counter(counter)
    modify_counter(counter, 1)
  end

  def decrease_counter(counter)
    modify_counter(counter, -1)
  end

  def increment_days_visited_once_per_day
    if last_incremented_at.nil? || last_incremented_at < Time.current.beginning_of_day
      self.days_visited += 1
      self.last_incremented_at = Time.current
      save
    end
  end
end
