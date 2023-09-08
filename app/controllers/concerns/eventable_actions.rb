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

  def near_events
    {
      past_events: past_events.as_json(EVENT_TO_JSON),
      next_events: next_events.as_json(EVENT_TO_JSON)
    }
  end
end
