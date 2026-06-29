# app/workers/low_stock_alert_worker.rb
class LowStockAlertWorker
  include Sidekiq::Worker

  # Configure worker to retry exactly 3 times and route to the alerts queue
  sidekiq_options queue: :alerts, retry: 3

  def perform(product_id, remaining_stock)
    product = Product.find_by(id: product_id)
    return unless product

    # Log the alert format cleanly to standard outputs
    timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S %Z")
    Rails.logger.warn "[LowStock] Product '#{product.name}' (SKU: #{product.sku}) has #{remaining_stock} units remaining — #{timestamp}"
  end
end