class CreateVenues < ActiveRecord::Migration[7.0]
  def change
    create_table :venues, id: :uuid do |t|
        t.string :description, null: false
        t.string :venue_name, null: false
  
        t.timestamps null: false
    end
  end
end