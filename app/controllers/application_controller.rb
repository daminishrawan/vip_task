# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  attr_reader :current_user

  before_action :authenticate_request!

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?
    decoded = JsonWebToken.decode(token) if token

    if decoded && decoded[:user_id]
      @current_user = User.find_by(id: decoded[:user_id])
    end

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: "Forbidden: Admin access required" }, status: :forbidden
    end
  end
end