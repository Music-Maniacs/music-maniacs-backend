class NewEventsNotificationsJob < ApplicationJob
  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event

    users_to_notify = Follow.where(followable_id: [event.artist.id, event.venue.id, event.producer.id])
                            .pluck(:user_id).uniq

    User.where(id: users_to_notify).find_each do |user|
      EventsNotificationMailer.with(user:, event:).new_event_from_follows.deliver_now
    end
  end
end
