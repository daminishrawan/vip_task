FactoryBot.define do
  factory :product do
    name { "MyString" }
    sku { "MyString" }
    price_cents { 1 }
    alcohol_by_volume { "9.99" }
    stock_quantity { 1 }
    brand { nil }
  end
end
