class Product < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :order_items
  has_many :carts, through: :order_items
  has_many :orders, through: :order_items
  has_many_attached :product_images
  
  scope :available, -> { where(active: true) }
  validates :stock, numericality: { greater_than_or_equal_to: 0, message: "cannot be less than zero" }
end
