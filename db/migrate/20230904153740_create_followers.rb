class CreateFollowers < ActiveRecord::Migration[7.0]
  def change
    create_table :followers, id: :uuid do |t|
      # followeable attrs
      t.uuid :user_id, foreign_key: true, index: true, null: false #  user_id
      t.uuid :followable_id, foreign_key: true, index: true, null: false
      t.string :followable_type, null: false, index: true
      t.timestamps
    end
  end
end
