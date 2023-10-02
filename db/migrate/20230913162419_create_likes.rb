class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true, type: :uuid
      t.references :likeable, polymorphic: true, null: false, index: true, type: :uuid

      t.timestamps
    end
  end
end
