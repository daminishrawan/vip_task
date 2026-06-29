# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    shipped: "shipped",
    cancelled: "cancelled"
  }, default: "pending"

  validates :status, presence: true
  validates :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Hook listens exclusively to status changes shifting towards confirmed states to enqueue background processing
  after_commit :check_low_stock_thresholds, if: -> { saved_change_to_status? && confirmed? }

  private

  def check_low_stock_thresholds
    order_items.includes(:product).each do |item|
      product = item.product
      if product.stock_quantity <= 10
        LowStockAlertWorker.perform_async(product.id, product.stock_quantity)
      end
    end
  end
end