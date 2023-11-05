class AddUniqueConstraintToUrlInLinks < ActiveRecord::Migration[7.0]
  def change
    remove_column :links, :url
    add_column :links, :url, :string, unique: true
  end
end
