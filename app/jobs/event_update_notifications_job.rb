class EventUpdateNotificationsJob < ApplicationJob
  def perform(event_id, changes)
    event = Event.find_by(id: event_id)
    return unless event

    event.followers.find_each do |user|
      EventsNotificationMailer.with(user:, event:, changes:).event_updates_to_followers.deliver_now
    end
  end
end