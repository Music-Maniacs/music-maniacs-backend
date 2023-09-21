class EventUpdateNotificationsJob < ApplicationJob
  def perform(event_id, changes)
    event = Event.find_by(id: event_id)
    return unless event

    users_to_notify = event.followers.pluck(:id)

    User.where(id: users_to_notify).find_each do |user|
      EventsNotificationMailer.with(user:, event:, changes:).event_updates_to_followers.deliver_now
    end
  end
end
