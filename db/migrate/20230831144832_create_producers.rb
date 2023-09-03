class CreateProducers < ActiveRecord::Migration[7.0]
  def change
    create_table :producers, id: :uuid do |t|
      t.string :name, null: false
      t.string :nationality
      t.string :description

      t.timestamps
    end
  end
end
