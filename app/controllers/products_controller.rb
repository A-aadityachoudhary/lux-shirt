class ProductsController < ApplicationController
    skip_before_action :require_authentication,
                     only: [:index, :show]
    def index
        @products = Product.includes(:category)
    end

    def show
        @product = Product.find(params[:id])
    end
end
