class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images, id: :uuid do |t|
      t.uuid :imageable_id, foreign_key: true, index: true, null: false
      t.string :imageable_type, index: true, null: false

      t.timestamps
    end
  end
end
