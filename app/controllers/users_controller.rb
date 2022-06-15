class UsersController < ApplicationController
  before_action :require_login
  before_action :find_user, only: [:edit, :update, :destroy]

  def admin
    if session[:id] == nil
      redirect_to sessions_path
    end

    if current_user.role.access == 1
      @user = User.all
      #@user = @user.sort_by { |id |id.shop_point  }
    end
    if current_user.role.access == 2
      @user = User.where(shop_point: current_user.shop_point)
      #@user = @user.sort_by { |id |id.shop_point  }
    end
    if current_user.role.access != 2 && current_user.role.access != 1
      redirect_to profile_path
    end
  end

  def new
    @user = User.new
    @current_user = current_user
  end

  def edit
    find_user
  end

  def update
    if @user.update(user_params)
      redirect_to admin_url
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      redirect_to admin_path
    else
      redirect_to admin_path, error: "Error in delete"
    end
  end

  def create
    @user = User.new(user_params)
    @user.id = SecureRandom.uuid

    if current_user.role.access == 2
      @user.shop_point = current_user.shop_point
    end
    if current_user.role.access == 2
      if @user.role.id == 2
        @user.destroy
      end
    end
    if @user.save
      if current_user.role.access == 1 && @user.role.access == 2
        @user.update(shop_point: SecureRandom.uuid)
      end
      redirect_to admin_url
    else
      render :new
    end
  end

  def show
    current_user
  end

  private

  def user_params
    params[:user].permit(:name, :surname, :email, :login, :password, :password_confirmation, :role_id)
  end

  def find_user
    @user = User.find(params[:id])
  end
end