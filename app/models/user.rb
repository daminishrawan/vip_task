# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy

  enum :role, { customer: "customer", admin: "admin" }, default: "customer"

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :role, presence: true
end