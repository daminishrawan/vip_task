# app/controllers/api/v1/brands_controller.rb
class Api::V1::BrandsController < ApplicationController
  def index
    # QUERY OPTIMIZATION: Resolves all brands and count using left_joins + group + select in 1 SQL query
    @brands = Brand.left_joins(:products)
                   .group(:id)
                   .select("brands.*, COUNT(products.id) AS product_count")

    render json: @brands.as_json(methods: :product_count)
  end

  def products
    @brand = Brand.find(params[:id])
    render json: @brand.products
  end
end