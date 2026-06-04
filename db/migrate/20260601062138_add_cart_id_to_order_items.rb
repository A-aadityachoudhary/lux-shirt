class AddCartIdToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :cart_id, :integer
  end
end
