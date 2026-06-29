# app/models/brand.rb
class Brand < ApplicationRecord
  has_many :products, dependent: :destroy

  enum :category, {
    beer: "beer",
    wine: "wine",
    spirits: "spirits",
    soft_drink: "soft_drink",
    juice: "juice"
  }

  validates :name, presence: true, uniqueness: true
  validates :country_of_origin, presence: true
  validates :category, presence: true
end
