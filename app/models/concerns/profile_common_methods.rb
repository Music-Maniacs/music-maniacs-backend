module ProfileCommonMethods
  EVENT_TO_JSON = { only: %i[id datetime name],
                    include:
                    { venue:
                      { only: %i[id name],
                        methods: %i[short_address] } } }.freeze

  def past_events
    events.where('datetime < ?', Time.now).order(datetime: :desc).limit(5).as_json(EVENT_TO_JSON)
  end

  def next_events
    events.where('datetime >= ?', Time.now).order(:datetime).limit(5).as_json(EVENT_TO_JSON)
  end
end
