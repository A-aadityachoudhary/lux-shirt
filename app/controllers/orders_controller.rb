class OrdersController < ApplicationController
    before_action :require_authentication
    def index
        @orders = Order.all
    end

    def show
        @order = Order.find(params[:id])
    end

    def new
        @order = Order.new
    end

    def create
        @order = Order.new(order_params)
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
        params.require(:order).permit(:name, :email, :address, :pay_method)
    end
end