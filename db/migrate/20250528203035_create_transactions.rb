class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :from_currency

      t.string :to_currency
      t.decimal :from_value
      t.decimal :to_value
      t.decimal :rate
      t.datetime :transaction_time

      t.timestamps
    end
  end
end
