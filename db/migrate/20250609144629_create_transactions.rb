class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :from_cur
      t.string :to_cur
      t.decimal :from_val
      t.decimal :to_val
      t.decimal :rate
      t.datetime :timestamp

      t.timestamps
    end
  end
end
