class AddTustLevelRequirementsToRoles < ActiveRecord::Migration[7.0]
  def change
    change_table(:roles) do |t|
      t.string :type
      t.integer :order
      t.integer :days_visited
      t.integer :viewed_events
      t.integer :likes_received
      t.integer :likes_given
      t.integer :comments_count
    end
  end
end
