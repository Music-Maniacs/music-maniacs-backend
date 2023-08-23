class CreatePermissionsRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions_roles, id: false do |t|
      t.belongs_to :role, type: :uuid
      t.belongs_to :permission, type: :uuid

      t.timestamps
    end
  end
end
