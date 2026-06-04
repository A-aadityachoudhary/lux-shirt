class Product < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :order_items
  has_many :carts, through: :order_items
  has_many :orders, through: :order_items
  has_many_attached :product_images

  scope :available, -> { where(active: true) }
  validates :stock, numericality: { greater_than_or_equal_to: 0, message: "cannot be less than zero" }
  after_update :clear_from_active_carts, if: :saved_change_to_active?

  def clear_from_active_carts
    # Run only when the product switches from Active (true) to Archived (false)
    if active == false
      # 1. Find all order_items belonging to this product
      # 2. Filter for items where the order_id is nil (meaning it is still in a cart, not a completed order)
      # 3. Destroy them completely so they vanish from the users' cart views
      order_items.where(order_id: nil).destroy_all
    end
  end
  
end
