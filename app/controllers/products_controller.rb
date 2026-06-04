class ProductsController < ApplicationController
    skip_before_action :require_authentication,
                     only: [:index, :show]
    def index
        @products = Product.includes(:category).where(active: true).order(created_at: :desc)
    end

    def show
        @product = Product.find(params[:id])
        unless @product.active?
            redirect_to root_path, alert: "This product release is currently unavailable."
        end
    end
end
