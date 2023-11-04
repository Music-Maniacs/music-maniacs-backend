class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :datetime, null: false

      t.belongs_to :artist, type: :uuid, foreign_key: true
      t.belongs_to :producer, type: :uuid, foreign_key: true
      t.belongs_to :venue, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
