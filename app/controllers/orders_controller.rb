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

    # 1. PRE-CHECK VALIDATIONS FIRST: Ensure every item actually fits within stock limits
    # We build the association in memory first to force the OrderItem validations to run.
    stock_is_valid = true
    
    @current_cart.order_items.each do |cart_item|
      # Build a temporary item linked to this order in memory to check its validation rule
      temp_item = @order.order_items.build(
        product_id: cart_item.product_id,
        quantity: cart_item.quantity
      )
      
      unless temp_item.valid?
        stock_is_valid = false
        @order.errors.add(:base, "Item '#{cart_item.product.title}' exceeds available stock limit.")
      end
    end

    # 2. INTERCEPT INSUFFICIENT STOCK: If any validation failed, stop immediately!
    unless stock_is_valid
      # Clear the temporary in-memory items so the form doesn't duplicate them on render
      @order.order_items.clear 
      flash.now[:alert] = "Order could not be created. One or more items exceed available stock."
      render :new, status: :unprocessable_entity and return
    end

    # 3. DATABASE TRANSACTION: Only enter here if everything is 100% valid
    ActiveRecord::Base.transaction do
      # Since we already verified stock availability, we can now safely save the base order shell
      if @order.save
        
        # Move the real cart items over to the saved order container
        @current_cart.order_items.each do |item|
          item.update!(order_id: @order.id)
          
          # Deduct stock safely from the product record
          product = item.product
          product.update!(stock: product.stock - item.quantity)
        end

        # Calculate the final bills and secure the instance
        @order.calculate_total_amount
        @order.save!

        # Wipe out the temporary cart tracking sessions cleanly
        @current_cart.order_items.update_all(cart_id: nil)
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        
        redirect_to order_path(@order), notice: "Thank you for your premium purchase!"
      else
        render :new, status: :unprocessable_entity
      end
    end

  rescue ActiveRecord::RecordInvalid => e
    # Fallback exception boundary catcher
    @order.order_items.clear if @order.present?
    redirect_to cart_path(@current_cart), alert: "Checkout aborted: System validation error encountered."
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