class OrdersController < ApplicationController
  before_action :require_authentication
  
  def index
    if Current.user.role == "admin"
      # Admins track all customer purchases globally
      @orders = Order.includes(:user, :order_items => :product).order(created_at: :desc)
    else
      # Regular users view only their personal order history
      @orders = Current.user.orders.includes(:order_items => :product).order(created_at: :desc)
    end
  end

  def show
    @order = Order.find(params[:id])
    if Current.user.role != "admin" && @order.user_id != Current.user.id
      redirect_to orders_path, alert: "Unauthorized access resource."
    end
  end

  def new
    @order = Order.new
  end

  def create
    @order = Current.user.orders.new(order_params)
    @order.status = "Pending" if @order.respond_to?(:status)

    # 1. Save the order container first so it achieves a real ID
    if @order.save
      # 2. Re-route the active cart items into this saved order container
      @current_cart.order_items.each do |item|
        item.update(order_id: @order.id)
      end

      # 3. Trigger the calculator method now that items are bound to it
      @order.calculate_total_amount
      @order.save # Re-save the final calculated total amount string

      # 4. Safely detach items from the temporary cart session & wipe it cleanly
      @current_cart.order_items.update_all(cart_id: nil)
      Cart.destroy(session[:cart_id])
      session[:cart_id] = nil
      
      redirect_to order_path(@order), notice: "Thank you for your premium purchase!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @order = Order.find(params[:id])
    
    if Current.user.role == "admin"
      if @order.update(order_params)
        redirect_to order_path(@order), notice: "Order ##{@order.id} status updated to #{@order.status}."
      else
        redirect_to order_path(@order), alert: "Failed to update order status."
      end
    else
      redirect_to orders_path, alert: "Unauthorized access operational controls."
    end
  end

  private

  def order_params
    params.require(:order).permit(:shipping_address, :payment_method, :status)
  end
end