module SessionsHelper

  def connect(user_id, all)
    session[:user] = {
      "id" => user_id,
      "all" => ActiveRecord::Type::Boolean.new.cast(all) }
  end

  def disconnect
    session.delete(:user)
  end

  def connected?
    !!User.valid_users.find_by(id: current_user_id)
  end

  def current_user_id
    session[:user] && session[:user]['id']
  end

  def current_user
    User.find_by(id: current_user_id)
  end

  def current_user_id?(user_id)
    current_user_id == user_id
  end

  def current_user_admin?
    current_user&.admin?
  end

  def show_all_events?
    !!session[:user] && session[:user]['all'] && current_user_admin?
  end

  def current_user_events
    Event.where(user_id: current_user_id)
  end
end
