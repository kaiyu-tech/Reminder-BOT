class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :line_id_digest, null: false
      t.string :line_name, null: false
      t.boolean :admin, null: false, default: false
      t.boolean :activate, null: false, default: false
      t.datetime :expires_in, precision: 6, default: nil
      t.string :notify_token_encrypt, default: nil
      t.datetime :reminded_at, precision: 6, default: nil

      t.timestamps
    end
    add_index :users, :line_id_digest, unique: true
  end
end
