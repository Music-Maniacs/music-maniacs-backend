class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments, id: :uuid do |t|
      t.text :body, null: false
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid, index: true
      t.belongs_to :event, null: false, foreign_key: true, type: :uuid, index: true

      t.timestamps null: false
    end
  end
end
