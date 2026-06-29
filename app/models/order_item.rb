# app/models/order_item.rb
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
