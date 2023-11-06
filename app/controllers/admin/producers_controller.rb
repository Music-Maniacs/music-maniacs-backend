class Admin::ProducersController < ApplicationController
  include Search
  PRODUCER_TO_JSON = { include: { genres: { only: %i[id name] },
                                  links: { only: %i[id url title] },
                                  image: { methods: %i[full_url] } } }.freeze

  SHOW_PRODUCER_TO_JSON = { include: { genres: { only: %i[id name] },
                                       links: { only: %i[id url title] },
                                       image: { methods: %i[full_url] },
                                       history: { except: :object_changes, methods: %i[named_object_changes anonymous], include: { user: { only: %i[id full_name] } } } } }.freeze

  def index
    producers = producers_scope.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: producers.as_json(PRODUCER_TO_JSON), pagination: pagination_info(producers) }
  end

  def show
    producer = producers_scope.find(params[:id])

    render json: producer.as_json(SHOW_PRODUCER_TO_JSON)
  end

  def create
    producer = Producer.new(producer_params)

    producer.image = Image.new(file: params[:image]) if params[:image].present?

    if producer.save
      producer.image.convert_to_webp

      render json: producer.as_json(SHOW_PRODUCER_TO_JSON), status: :ok
    else
      render json: { errors: producer.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    producer = producers_scope.find(params[:id])

    if params[:image].present?
      if producer.image.present?
        producer.image.file.purge
        producer.image.file.attach(params[:image])
      else
        producer.image = Image.new(file: params[:image])
      end
    end

    if producer.update(producer_params)
      producer.image.convert_to_webp

      render json: producer.as_json(SHOW_PRODUCER_TO_JSON), status: :ok
    else
      render json: { errors: producer.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    producer = producers_scope.find(params[:id])

    if producer.destroy
      head :no_content, status: :ok
    else
      render json: { errors: producer.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def producers_scope
    Producer.with_deleted
  end

  def producer_params
    JSON.parse(params.require(:producer)).deep_symbolize_keys.slice(:name, :description, :nationality, :links_attributes, :genre_ids)
  end
end
