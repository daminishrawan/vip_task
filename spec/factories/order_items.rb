FactoryBot.define do
  factory :order_item do
    quantity { 1 }
    unit_price_cents { 1 }
    order { nil }
    product { nil }
  end
end
