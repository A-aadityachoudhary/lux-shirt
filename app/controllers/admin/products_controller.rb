class Admin::ProductsController < ApplicationController
  before_action :require_authentication
  before_action :authenticate_admin
  before_action :set_product, only: %i[ edit update destroy ]
  
  def index
    @products = Current.user.products
  end

  def new
    @product = Product.new
  end

  def create
    @product = Current.user.products.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/products/:id/edit
  def edit
  end

  # PATCH/PUT /admin/products/:id
  def update
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Product successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/products/:id
  def destroy
    # Flip the active boolean flag instead of running a SQL DELETE query
    if @product.update(active: false)
      # status: :see_other informs Turbo to instantly refresh the index display view state
      redirect_to admin_products_path, status: :see_other, notice: "Product has been successfully archived."
    else
      redirect_to admin_products_path, alert: "Could not modify product lifecycle status."
    end
  end

  private

  def set_product
    @product = Current.user.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_products_path, alert: "Product not found or unauthorized access."
  end

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