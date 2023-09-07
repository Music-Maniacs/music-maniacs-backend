module Search
  extend ActiveSupport::Concern

  def search_typeahead
    artists = search_model_scope.ransack(params[:q]).result(distinct: true).limit(10).pluck(:id, :name)

    render json: artists.map { |artist| { value: artist[0], label: artist[1] } }
  end

  private

  # can be redefined
  def search_model_scope
    controller_path.classify.split('::').last.constantize
  end
end
