module ProfileCommonMethods
  EVENT_TO_JSON = { only: %i[datetime],
                    include:
                    { venue:
                      { only: %i[name],
                        methods: %i[address] } } }.freeze

  def past_events
    events.where('datetime < ?', Time.now).order(datetime: :desc).limit(5).as_json(EVENT_TO_JSON)
  end

  def next_events
    events.where('datetime >= ?', Time.now).order(:datetime).limit(5).as_json(EVENT_TO_JSON)
  end
end
