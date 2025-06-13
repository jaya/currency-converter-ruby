FactoryBot.define do
  factory :transaction do
    association :user
    from_cur { "USD" }
    to_cur { "BRL" }
    from_val { 100 }
    to_val { 525.32 }
    rate { 5.2532 }
    timestamp { Time.current.utc }
  end
end
