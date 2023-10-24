class AddCityRemoveLocalityAndDepartmentOnLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :city, :string

    Location.find_each do |location|
      location.update(city: location.locality) if location.locality.present?
    end

    remove_column :locations, :department, :string
    remove_column :locations, :locality, :string
  end
end
