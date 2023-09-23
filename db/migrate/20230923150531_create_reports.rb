class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports, id: :uuid do |t|
      t.text :moderator_comment
      t.text :user_comment
      t.integer :penalization_score
      t.integer :status
      t.integer :category

      t.references :reporter, type: :uuid, null: false, foreign_key: true
      t.references :resolver, type: :uuid, null: false, foreign_key: true
      t.references :reportable, type: :uuid, null: false, polymorphic: true

      t.timestamps
    end
  end
end
