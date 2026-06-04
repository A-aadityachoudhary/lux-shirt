class Admin::ProductsController < ApplicationController
  before_action :require_authentication
  before_action :authenticate_admin
  before_action :set_product, only: %i[ edit update destroy toggle_active]
  
  def index
    @active_products   = Current.user.products.where(active: true).order(created_at: :desc)
    @archived_products = Current.user.products.where(active: false).order(created_at: :desc)
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

  def toggle_active
    new_status = !@product.active
    
    if @product.update(active: new_status)
      status_msg = new_status ? "Product is now live on the storefront!" : "Product has been archived."
      # status: :see_other breaks Turbo caching and instantly forces both tables to re-draw
      redirect_to admin_products_path, status: :see_other, notice: status_msg
    else
      redirect_to admin_products_path, alert: "Lifecycle update rejected."
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