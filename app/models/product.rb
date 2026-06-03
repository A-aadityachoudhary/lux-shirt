class Product < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :carts, through: :order_items
  has_many :orders, through: :order_items
  has_many_attached :product_images
end
