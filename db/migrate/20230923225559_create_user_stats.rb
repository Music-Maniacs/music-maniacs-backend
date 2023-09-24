class CreateUserStats < ActiveRecord::Migration[7.0]
  def change
    create_table :user_stats, id: :uuid do |t|
      t.integer :days_visited
      t.datetime :last_incremented_at
      t.integer :viewed_events
      t.integer :likes_received
      t.integer :likes_given
      t.integer :comments_count
      t.belongs_to :user, foreign_key: true, index: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
