class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos, id: :uuid do |t|
      t.uuid :videable_id, foreign_key: true, index: true, null: false
      t.string :videable_type, index: true, null: false
      t.datetime :recorded_at

      t.timestamps
    end
  end
end