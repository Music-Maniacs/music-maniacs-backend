class EventUpdateNotificationsJob < ApplicationJob
  def perform(event_id, changes)
    event = Event.find_by(id: event_id)
    return unless event

    event.followers.find_each do |user|
      EventsNotificationMailer.with(user:, event:, changes:).event_updates_to_followers.deliver_now
    end
  end

  class EventDestroyNotificationsJob < ApplicationJob
    def perform(event_id)
      event = Event.find_by(id: event_id)
      return unless event
  
      event.followers.find_each do |user|
        EventsNotificationMailer.with(user: user, event: event, deleted: true).event_destroy_to_followers.deliver_now
      end
    end
end