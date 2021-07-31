class CreateReminders < ActiveRecord::Migration[6.0]
  def change
    create_table :reminders do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :number, null: false, default: 0
      t.integer :unit, null: false, default: 0
      t.datetime :remind_at, precision: 6, default: nil

      t.timestamps
    end
  end
end
