class CreatePenaltyThresholds < ActiveRecord::Migration[7.0]
  def change
    create_table :penalty_thresholds, id: :uuid do |t|
      t.integer :penalty_score, null: false
      t.integer :days_blocked, null: false

      t.timestamps
    end
  end
end
