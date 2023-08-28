class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations,id: :uuid do |t|
      t.string :zip_code
      t.string :street
      t.string :department
      t.string :locality
      t.string :latitude
      t.string :longitude
      t.integer :number
      t.string :country
      t.string :province
      
      ## relation
      t.uuid :venue_id, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
