class Admin::ProductsController < ApplicationController
    before_action :require_authentication
    before_action :authenticate_admin
    
    def index
        @products = Current.user.products
    end

    def new
        @product = Product.new
    end

    def create
        @product = Current.user.products.new(product_params)
        if @product.save
            redirect_to admin_products_path
        else
            render :new
        end
    end

    private
    def product_params
        params.require(:product).permit(
          :title,
          :description,
          :price,
          :stock,
          :category_id,
          product_images: []
        )
    end
end
