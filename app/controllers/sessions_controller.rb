class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create, raise: false

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    # If the user exists AND the password entered is correct.
    if user && user.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = user.id
      redirect_to root_path
    else
      # If user's login doesn't work, send them back to the login form.
      flash[:error] = "Unknown user"
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end

end
