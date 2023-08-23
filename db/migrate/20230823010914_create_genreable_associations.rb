class CreateGenreableAssociations < ActiveRecord::Migration[7.0]
  def change
    create_table :genreable_associations, id: :uuid do |t|
      t.belongs_to :genre, foreign_key: true, index: true, null: false, type: :uuid

      t.uuid :genreable_id, foreign_key: true, index: true, null: false
      t.string :genreable_type, index: true, null: false

      t.timestamps
    end
  end
end
