class OrderItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true
  validates :quantity, numericality: { greater_than: 0 }
  validate :stock_availability

  private

  def stock_availability
    if product.present? && quantity.present?
      if quantity > product.stock
        errors.add(:quantity, "ordered (#{quantity}) exceeds total units remaining in stock (#{product.stock})")
      end
    end
  end
end
