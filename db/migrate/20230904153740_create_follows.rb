class CreateFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true, type: :uuid
      t.references :followable, polymorphic: true, null: false, index: true, type: :uuid

      t.timestamps
    end
  end
end
