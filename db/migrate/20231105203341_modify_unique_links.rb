class ModifyUniqueLinks < ActiveRecord::Migration[7.0]
  def change
    add_index :links, :url, unique: true
  end
end
