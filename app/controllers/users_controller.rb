class UsersController < ApplicationController
  before_action :check_login
  before_action :set_user, only: [:settings, :update]

  def new
    @user = User.new
  end

  def edit
    if current_user.admin
      @user = User.find(params[:id])
    end
  end

  def create
    @user = User.create(user_params)
    # session[:user_id] = @user.id
    redirect_to settings_path
  end

  def show
  end

  def settings
    if @user.admin
      @users = User.all.where.not(id: @user.id)
    end
  end

  def update
    if current_user.admin
      @user = User.find(params[:id]) 
      if @user.update(user_params)
        redirect_to settings_path, notice: "User #{@user.username} was revised in the system."
      elsif @user == current_user
        render action: 'settings'
      else
        render action: 'edit'
      end
    else
      if @user.update(user_params)
        redirect_to settings_path, notice: "User #{@user.username} was revised in the system."
      else
        render action: 'settings'
      end
    end
  end

  def destroy
    if current_user.admin
      User.find(params[:id]).destroy
    end
    redirect_to settings_path
  end

  private
  def set_user
    @user = User.find(session[:user_id])
  end

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :api_key, :admin)
  end
end
