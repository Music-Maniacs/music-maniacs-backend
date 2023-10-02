module ReviewableActions
  extend ActiveSupport::Concern

  REVIEW_TO_JSON = { only: %i[id rating description created_at reviewable_type],
                     include: { user: { only: %i[id full_name] } },
                     methods: :anonymous }.freeze

  def reviews
    reviews_result = search_model_scope.find(params[:id]).reviews.page(params[:page]).per(params[:per_page])

    render json: { data: reviews_result.as_json(REVIEW_TO_JSON), pagination: pagination_info(reviews_result) }
  end

  private

  # can be redefined
  def search_model_scope
    controller_path.classify.constantize
  end
end
