class ProducersController < ApplicationController
  PRODUCER_TO_JSON = { include: { genres: { only: %i[id name] },
                                  links: { only: %i[id url title] },
                                  image: { methods: %i[url] } } }.freeze

  def show
    producer = Producer.find(params[:id])
    past_events = producer.events.past_events
    future_events = producer.events.furute_events
    versions = producer.versions

    render json: { producer: producer.as_json(PRODUCER_TO_JSON),
                   events: {
                     past_events: past_events,
                     future_events: future_events
                   },
                   versions: versions.map { |version| version.as_json } }
  end

  def create
    producer = Producer.new(producer_params)

    producer.image = Image.new(file: params[:image]) if params[:image].present?

    if producer.save
      render json: producer.as_json(PRODUCER_TO_JSON), status: :ok
    else
      render json: { errors: producer.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    producer = Producer.find(params[:id])

    if params[:image].present?
      if producer.image.present?
        producer.image.file.purge
        producer.image.file.attach(params[:image])
      else
        producer.image = Image.new(file: params[:image])
      end
    end

    if producer.update(producer_params)
      render json: producer.as_json(PRODUCER_TO_JSON), status: :ok
    else
      render json: { errors: producer.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def producer_params
    JSON.parse(params.require(:producer)).deep_symbolize_keys.slice(:name,
                                                                    :description,
                                                                    :nationality,
                                                                    :links_attributes,
                                                                    :genre_ids)
  end
end
