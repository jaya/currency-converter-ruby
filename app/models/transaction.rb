class Transaction < ApplicationRecord
  ALLOWED_CURRENCIES = %w[BRL USD EUR JPY].freeze

  validates :user_id, presence: true
  validates :from_currency, presence: true, length: { is: 3 }
  validates :to_currency, presence: true, length: { is: 3 }
  validates :from_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :to_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :rate, presence: true, numericality: { greater_than: 0 }

  validates :from_currency, inclusion: { in: ALLOWED_CURRENCIES,
                                        message: "%{value} is not a supported currency" }
  validates :to_currency, inclusion: { in: ALLOWED_CURRENCIES,
                                      message: "%{value} is not a supported currency" }

  validate :different_currencies

  def as_json
    {
      transaction_id: id,
      user_id: user_id,
      from_currency: from_currency,
      to_currency: to_currency,
      from_value: from_value.to_f, # so when transformed to JSON, it will be a float
      to_value: to_value.to_f,
      rate: rate.to_f,
      timestamp: created_at.iso8601
    }
  end

  private

  def different_currencies
    if from_currency == to_currency
      errors.add(:base, "Origin and destination currencies cannot be the same.")
    end
  end
end
