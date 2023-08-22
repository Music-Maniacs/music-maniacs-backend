class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links, id: :uuid do |t|
      t.string :title
      t.string :url

      # lìnkeable attrs
      t.uuid :linkeable_id, foreign_key: true, index: true, null: false
      t.string :linkeable_type, null: false, index: true

      t.timestamps
    end
  end
end
