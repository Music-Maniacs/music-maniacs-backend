class AddViewsCountAndPopularityScoreToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :views_count, :bigint, default: 0
    add_column :events, :popularity_score, :bigint, default: 0
  end
end
