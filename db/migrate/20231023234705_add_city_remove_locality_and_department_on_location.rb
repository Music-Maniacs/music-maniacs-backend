class AddCityRemoveLocalityAndDepartmentOnLocation < ActiveRecord::Migration[7.0]
  def change
    rename_column :locations, :department, :city

    remove_column :locations, :locality, :string
  end
end
