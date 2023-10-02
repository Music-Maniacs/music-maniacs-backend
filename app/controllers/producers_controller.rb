class ProducersController < ApplicationController
  include FollowableActions
  include ReviewableActions

  PRODUCER_TO_JSON = { include: { genres: { only: %i[id name] },
                                  links: { only: %i[id url title] },
                                  image: { methods: %i[full_url] },
                                  last_reviews: { only: %i[id rating description created_at reviewable_type],
                                                  include: { user: { only: %i[id full_name] } },
                                                  methods: :anonymous },
                                  versions: { methods: :anonymous, include: { user: { only: %i[id full_name] } } } },
                       methods: %i[rating past_events next_events] }.freeze

  def show
    producer = Producer.find(params[:id])
    producer_json = producer.as_json(PRODUCER_TO_JSON)

    producer_json['followed_by_current_user'] = if current_user.present?
                                                  current_user.follows?(producer)
                                                else
                                                  false
                                                end
    render json: producer_json, status: :ok
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
