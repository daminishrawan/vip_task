# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def create
    items_params = params[:order_items] || []

    if items_params.empty?
      return render json: { error: "Order items cannot be empty" }, status: :unprocessable_entity
    end

    # Database transaction wraps inventory checks and line creation
    Order.transaction do
      @order = current_user.orders.build(status: :pending)
      total_cents = 0

      items_params.each do |item|
        product = Product.with_lock.find(item[:product_id]) # Lock record to handle concurrency race conditions

        if product.stock_quantity < item[:quantity].to_i
          # Explicitly raise exception to force atomic rollback across transaction block
          raise ActiveRecord::RecordInvalid.new(product), "Insufficient stock for product '#{product.name}'"
        end

        # Deduct quantity and prepare line item parameters
        product.update!(stock_quantity: product.stock_quantity - item[:quantity].to_i)
        
        line_price = product.price_cents * item[:quantity].to_i
        total_cents += line_price

        @order.order_items.build(
          product: product,
          quantity: item[:quantity],
          unit_price_cents: product.price_cents # Snapshot price at order submission
        )
      end

      @order.total_cents = total_cents
      @order.save!
    end

    render json: @order, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    @order = Order.find(params[:id])

    # SECURITY CHECK: Customers can only look up their personal history files
    if current_user.customer? && @order.user_id != current_user.id
      return render json: { error: "Forbidden access" }, status: :forbidden
    end

    # QUERY OPTIMIZATION: Includes product associations to prevent N+1 lookups on line items
    render json: @order.as_json(
      include: {
        order_items: {
          include: { product: { only: :name } }
        }
      }
    )
  end

  def cancel
    @order = Order.find(params[:id])

    # SECURITY CHECK: Customers cannot alter other accounts' order states
    if current_user.customer? && @order.user_id != current_user.id
      return render json: { error: "Forbidden access" }, status: :forbidden
    end

    # BUSINESS RULE: Orders can only be canceled if they remain in pending states
    if @order.pending?
      @order.update!(status: :cancelled)
      render json: @order, status: :ok
    else
      render json: { error: "Cannot cancel order that is already #{@order.status}" }, status: :unprocessable_entity
    end
  end

  def create
  # Extract and permit array items safely
  items_payload = params[:items]

  if items_payload.blank? || !items_payload.is_a?(Array)
    return render json: { error: "Order items cannot be empty" }, status: :unprocessable_entity
  end

  Order.transaction do
    @order = current_user.orders.build(status: :pending, total_cents: 0)
    total = 0

    items_payload.each do |item_data|
      # Look up product with lock
      product = Product.lock.find(item_data[:product_id])
      requested_qty = item_data[:quantity].to_i

      if product.stock_quantity < requested_qty
        render json: { error: "Insufficient stock for product '#{product.name}'" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # Deduct inventory immediately inside lock
      product.update!(stock_quantity: product.stock_quantity - requested_qty)

      item_price = product.price_cents
      total += item_price * requested_qty

      @order.order_items.build(
        product: product,
        quantity: requested_qty,
        unit_price_cents: item_price
      )
    end

    @order.total_cents = total
    @order.status = :confirmed

    if @order.save
      render json: @order, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end
  end
end
end