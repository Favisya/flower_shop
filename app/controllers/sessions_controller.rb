class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  def new

  end

  def index
    redirect_to new_session_path
  end

  def create
    session_params = params.permit(:login, :password)
    @user = User.find_by(login: session_params[:login])
    if @user && @user.authenticate(session_params[:password])
      session[:id] = @user.id
      redirect_to profile_url
    else
      redirect_to new_session_path
    end
  end

  def session_check
    if session[:id] == nil
      redirect_to sessions_path
    else

    end
  end

  def destroy
    session[:id] = nil
    flash[:notice] = "You have been signed out!"
    redirect_to new_session_path
  end
end
