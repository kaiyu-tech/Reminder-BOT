require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @admin = users(:admin)
    @user = users(:user_1)
  end

  test "connect as admin when all is false" do
    user_id = @admin.id
    all = false

    connect(user_id, all)
    assert_equal session[:user]['id'], user_id
    assert_equal session[:user]['all'], all

    assert connected?
    assert_equal current_user_id, user_id
    assert_equal current_user, User.find_by(id: user_id)
    assert current_user_id?(user_id)
    assert current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events, Event.where(user_id: user_id)

    disconnect
    assert_nil session[:user]

    assert_not connected?
    assert_nil current_user_id
    assert_nil current_user
    assert_not current_user_id?(user_id)
    assert_not current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events.size, 0
  end

  test "connect as admin when all is true" do
    user_id = @admin.id
    all = true

    connect(user_id, all)
    assert_equal session[:user]['id'], user_id
    assert_equal session[:user]['all'], all

    assert connected?
    assert_equal current_user_id, user_id
    assert_equal current_user, User.find_by(id: user_id)
    assert current_user_id?(user_id)
    assert current_user_admin?
    assert show_all_events?
    assert_equal current_user_events, Event.where(user_id: user_id)

    disconnect
    assert_nil session[:user]

    assert_not connected?
    assert_nil current_user_id
    assert_nil current_user
    assert_not current_user_id?(user_id)
    assert_not current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events.size, 0
  end

  test "connect as user when all is false" do
    user_id = @user.id
    all = false

    connect(user_id, all)
    assert_equal session[:user]['id'], user_id
    assert_equal session[:user]['all'], all

    assert connected?
    assert_equal current_user_id, user_id
    assert_equal current_user, User.find_by(id: user_id)
    assert current_user_id?(user_id)
    assert_not current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events, Event.where(user_id: user_id)

    disconnect
    assert_nil session[:user]

    assert_not connected?
    assert_nil current_user_id
    assert_nil current_user
    assert_not current_user_id?(user_id)
    assert_not current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events.size, 0
  end

  test "connect as user when all is true" do
    user_id = @user.id
    all = true

    connect(user_id, all)
    assert_equal session[:user]['id'], user_id
    assert_equal session[:user]['all'], all

    assert connected?
    assert_equal current_user_id, user_id
    assert_equal current_user, User.find_by(id: user_id)
    assert current_user_id?(user_id)
    assert_not current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events, Event.where(user_id: user_id)

    disconnect
    assert_nil session[:user]

    assert_not connected?
    assert_nil current_user_id
    assert_nil current_user
    assert_not current_user_id?(user_id)
    assert_not current_user_admin?
    assert_not show_all_events?
    assert_equal current_user_events.size, 0
  end
end