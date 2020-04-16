class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :logged_in?
  
  def current_user    
    User.find_by(id: session[:user_id])  
  end

  def logged_in?    
    current_user
  end

  # handle 404 errors with an exception as well
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Seek and you shall find... but not this time"
    p "Seek and you shall find... but not this time"
    redirect_to home_path
  end

  def check_login
    redirect_to login_path, alert: "You need to log in to view this page." if current_user.nil?
  end
end
