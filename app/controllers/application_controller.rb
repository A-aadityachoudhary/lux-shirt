class ApplicationController < ActionController::Base
  include Authentication
  before_action :require_current_user_presence
  def authenticate_admin
    unless Current.user.role == "admin"
      redirect_to root_path
    end
  end

  before_action :current_cart

  private

  def require_current_user_presence
    if respond_to?(:resume_session)
      resume_session
    end
  end

  def current_cart
  return unless Current.user  # Don't create cart for guests

  if session[:cart_id]
    cart = Cart.find_by(id: session[:cart_id])
    if cart.present?
      @current_cart = cart
    else
      session[:cart_id] = nil
    end
  end

  if session[:cart_id].nil?
    @current_cart = Cart.create
    session[:cart_id] = @current_cart.id
  end
end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
