class OrdersController < ApplicationController
    before_action :require_authentication
    def index
        @orders = Current.user.orders.order(created_at: :desc)
    end

    def show
        @order = Order.find(params[:id])
    end

    def new
        @order = Order.new
    end

    def create
        @order = Current.user.orders.new(order_params)
        @current_cart.order_items.each do |item|
            item.update(
              cart_id: nil,
              order_id: @order.id
            )
        end
        @order.save
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        redirect_to root_path
    end
    private
    def order_params
        params.require(:order).permit(:shipping_address, :payment_method)
    end
end