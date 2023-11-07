class EventDestroyNotificationsJob < ApplicationJob
  def perform(event_id)
    event = Event.with_deleted.find_by(id: event_id)
    return unless event

    event.followers.find_each do |user|
      EventsNotificationMailer.with(user:, event:).event_destroys_to_followers.deliver_now
    end
  end
end
