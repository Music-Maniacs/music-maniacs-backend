class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports, id: :uuid do |t|
      t.text :moderator_comment
      t.text :user_comment
      t.integer :penalization_score
      t.integer :status, default: 0
      t.integer :category

      t.uuid :reporter_id, null: false, foreign_key: true
      t.uuid :resolver_id, foreign_key: true
      t.uuid :reportable_id, null: false
      t.string :reportable_type, null: false
      t.uuid :original_reportable_id # este es para cuando se reporta que algo está duplicado y hay un original

      t.timestamps
    end
  end
end
