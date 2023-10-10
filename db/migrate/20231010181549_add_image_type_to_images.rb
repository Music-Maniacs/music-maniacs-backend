class AddImageTypeToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :image_type, :string, default: 'profile'
  end
end
