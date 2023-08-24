class CreateVenues < ActiveRecord::Migration[7.0]
  def change
    create_table :venues,id: :uuid do |t|
        
        t.string :description, null: false
        t.string :venue_name, null: false
  
        # lìnkeable attrs
        t.uuid :linkeable_id, foreign_key: true, index: true#, null: false
        t.string :linkeable_type, index: true#, null: false
  
        t.timestamps null: false
    end
  end
end
