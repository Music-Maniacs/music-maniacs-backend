class AddDeletedAtToReportables < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :deleted_at, :datetime
    add_index :comments, :deleted_at
    add_column :artists, :deleted_at, :datetime
    add_index :artists, :deleted_at
    add_column :venues, :deleted_at, :datetime
    add_index :venues, :deleted_at
    add_column :events, :deleted_at, :datetime
    add_index :events, :deleted_at
    add_column :producers, :deleted_at, :datetime
    add_index :producers, :deleted_at
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
  end
end
