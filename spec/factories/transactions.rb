FactoryBot.define do
  factory :transaction do
    user_id { 1 }
    from_currency { "MyString" }
    to_currency { "MyString" }
    from_value { "9.99" }
    to_value { "9.99" }
    rate { "9.99" }
    transaction_time { "2025-05-28 17:30:36" }
  end
end
