class Admin::ProducersController < ApplicationController
  include Search
  before_action :validate_user_is_admin, except: :search_typeahead

  PRODUCER_TO_JSON = { include: { genres: { only: %i[id name] },
                                  links: { only: %i[id url title] },
                                  image: { methods: %i[full_url] } } }.freeze

  def index
    producers = Producer.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: producers.as_json(PRODUCER_TO_JSON), pagination: pagination_info(producers) }
  end

  def show
    producer = Producer.find(params[:id])

    render json: producer.as_json(PRODUCER_TO_JSON)
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

  def destroy
    producer = Producer.find(params[:id])

    if producer.destroy
      head :no_content, status: :ok
    else
      render json: { errors: producer.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def producer_params
    JSON.parse(params.require(:producer)).deep_symbolize_keys.slice(:name, :description, :nationality, :links_attributes, :genre_ids)
  end
end
