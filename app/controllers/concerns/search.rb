module Search
  def search_typeahead
    collection = search_model_scope.ransack(params[:q]).result(distinct: true).limit(10).pluck(:id, :name)

    render json: collection.map { |element| { value: element[0], label: element[1] } }
  end

  private

  # can be redefined
  def search_model_scope
    controller_path.classify.split('::').last.constantize
  end
end
