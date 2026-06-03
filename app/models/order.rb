class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :payment
  
  def calculate_total_amount
    self.total_amount = order_items.sum { |item| item.quantity * item.product.price }
  end
end