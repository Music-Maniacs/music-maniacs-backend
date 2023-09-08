module EventableActions
  EVENT_TO_JSON = { only: %i[name datetime],
                    include: {
                      venue: {
                        only: %i[name id],
                        include: {
                          location: {
                            only: %i[country province] } } } } }.freeze

  def past_events
    events.where('datetime < ?', Time.now).order(datetime: :desc).limit(5)
  end

  def next_events
    events.where('datetime >= ?', Time.now).order(:datetime).limit(5)
  end

  def events_to_json(events)
    events.as_json(EVENT_TO_JSON)
  end

  def near_events
    {
      past_events: events_to_json(past_events),
      next_events: events_to_json(next_events)
    }
  end
end
