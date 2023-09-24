class CreateUserStats < ActiveRecord::Migration[7.0]
  def change
    create_table :user_stats, id: :uuid do |t|
      t.datetime :last_day_visited
      t.integer :days_visited
      t.integer :viewed_events
      t.integer :likes_received
      t.integer :likes_given
      t.integer :comments_count
      t.integer :penalty_score
      t.belongs_to :user, foreign_key: true, index: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
