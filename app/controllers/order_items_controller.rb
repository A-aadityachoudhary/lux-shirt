class OrderItemsController < ApplicationController

  def create
    product = Product.find(params[:product_id])

    order_item = @current_cart.order_items.find_by(product_id: product.id)

    if order_item
      order_item.quantity += 1
    else
      order_item = @current_cart.order_items.build(
        product: product,
        quantity: 1
      )
    end

    if order_item.save
      redirect_to cart_path(@current_cart),
                  notice: "Product added to cart"
    else
      redirect_to product_path(product),
                  alert: order_item.errors.full_messages.join(", ")
    end
  end

  def increase_quantity
    order_item = OrderItem.find(params[:id])
    order_item.increment!(:quantity)

    redirect_to cart_path(@current_cart)
  end

  def reduce_quantity
    order_item = OrderItem.find(params[:id])

    if order_item.quantity > 1
      order_item.decrement!(:quantity)
    else
      order_item.destroy
    end

    redirect_to cart_path(@current_cart)
  end

end