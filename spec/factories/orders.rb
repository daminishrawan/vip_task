FactoryBot.define do
  factory :order do
    status { "MyString" }
    total_cents { 1 }
    user { nil }
  end
end
