# app/controllers/api/v1/products_controller.rb
class Api::V1::ProductsController < ApplicationController
  before_action :require_admin!, only: [:create, :update]

  def index
    # CACHING: Compute cache key dynamically using a digest of the query filters
    category = params[:category]
    in_stock = params[:in_stock] == "true"

    cache_key = "products_list:cat_#{category || 'all'}:in_stock_#{in_stock}"

    @products = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      scope = Product.includes(:brand) # Eager load brand names to prevent N+1 queries
      scope = scope.where(brands: { category: category }) if category.present?
      scope = scope.where("stock_quantity > ?", 0) if in_stock
      
      # Map data array for serializing to make sure it's safely cached as primitive data structures
      scope.map do |product|
        {
          id: product.id,
          name: product.name,
          sku: product.sku,
          price_cents: product.price_cents,
          stock_quantity: product.stock_quantity,
          alcohol_by_volume: product.alcohol_by_volume,
          brand_name: product.brand.name
        }
      end
    end

    render json: @products
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :sku, :price_cents, :alcohol_by_volume, :stock_quantity, :brand_id)
  end
end