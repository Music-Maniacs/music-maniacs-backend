class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :name, null: false
      t.string :action, null: false
      t.string :subject_class, null: false
      t.string :subject_id

      t.timestamps
    end
  end
end
