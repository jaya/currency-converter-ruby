class Transaction < ApplicationRecord
    belongs_to :user
    validates :user_id, :from_cur, :to_cur, presence: true
    validates :from_val, numericality: { greater_than: 0 }

    CURRENCIES = [ "BRL", "USD", "EUR", "JPY", "GBP", "CAD" ] # Update here if more currencies are needed...
end
