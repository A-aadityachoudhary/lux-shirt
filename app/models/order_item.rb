class OrderItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true
  validates :quantity, numericality: { greater_than: 0 }
end
