class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews, id: :uuid do |t|
      t.integer :rating, null: false
      t.text :description
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid, index: true
      t.belongs_to :event, null: false, foreign_key: true, type: :uuid, index: true
      t.references :reviewable, polymorphic: true, null: false, type: :uuid, index: true

      t.timestamps
    end
  end
end
