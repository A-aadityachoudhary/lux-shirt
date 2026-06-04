class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    if user = User.authenticate_by(session_params)
      start_new_session_for user
      
      # If user logs in as an administrator, bypass the standard home paths
      if user.role == "admin"
        redirect_to admin_products_path, notice: "Welcome back, Admin."
      else
        redirect_to after_authentication_url || root_path, status: :see_other, notice: "Signed in successfully."
      end
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
  def session_params
    params.permit(:email_address, :password).to_h.symbolize_keys
  end
end