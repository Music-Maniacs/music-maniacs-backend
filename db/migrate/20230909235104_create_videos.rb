class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos, id: :uuid do |t|
      t.datetime :recorded_at
      t.belongs_to :event, type: :uuid, null: false, foreign_key: true
      t.belongs_to :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end