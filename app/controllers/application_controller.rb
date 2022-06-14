class ApplicationController < ActionController::Base

  before_action :require_login
  flag = 0

  if flag == 0
    i = 1
    array = ["", "Главный Администратор", "Управляющий", "Флорист"]
    while i < 4

      role = Role.new
      role.position = array[i]
      role.access = i
      role.id = i
      if Role.find_by(id: i) != role
        role.save
      end
      i += 1
    end

    user = User.new
    user.name = "admin"
    user.surname = "admin"
    user.password = "admin"
    user.login = "admin"
    user.email = "admin"
    user.id = "admin"
    user.shop_point = "admin"
    user.role_id = 1
    user.save

    flag = 1
  end

  def require_login
    redirect_to new_session_path unless session.include? :id
  end

  def current_user
    @current_user ||= User.find(session[:id]) if session[:id]
  end

end

