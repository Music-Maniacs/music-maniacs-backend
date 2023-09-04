class CreateFollowers < ActiveRecord::Migration[7.0]
  def change
    create_table :followers, id: :uuid do |t|
      t.uuid :follower_id, foreign_key: true, index: true, null: false # id usuario que sigue otro modelo
      t.references :followable, polymorphic: true, null: false, index: true # id del modelo que sigue el usuario

      t.timestamps
    end

    add_index :followers,
              %i[follower_id followable_type followable_id],
              unique: true,
              name: 'index_followers_on_follower_and_followable'
  end
end
