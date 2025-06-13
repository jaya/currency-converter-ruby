json.extract! transaction, :id, :user_id, :from_cur, :to_cur, :from_val, :to_val, :rate, :timestamp, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
