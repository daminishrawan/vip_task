# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :brand
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :alcohol_by_volume, numericality: { greater_than_or_equal_to: 0.0 }, allow_nil: true

  # Invalidate cached product collection results after any database modification
  after_commit :clear_products_cache

  private

  def clear_products_cache
    # Since filter keys can vary dynamically, we target the pattern namespaces matching our API responses
    Rails.cache.delete_matched("products_list:*")
  end
end
