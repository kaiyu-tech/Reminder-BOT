class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, default: nil
      t.date :start_date, default: nil
      t.date :end_date, default: nil
      t.time :start_time, precision: 6, default: nil
      t.time :end_time, precision: 6, default: nil
      t.integer :day_of_week, default: nil
      t.integer :with_order, default: nil
      t.integer :week_of_month, default: nil
      t.integer :day_of_month, default: nil
      t.datetime :start_datetime, precision: 6, null: false
      t.datetime :end_datetime, precision: 6, null: false

      t.timestamps
    end
  end
end
