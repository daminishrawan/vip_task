# app/controllers/api/v1/auth_controller.rb
class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request!, only: [:login]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, expires_in: "24h" }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end