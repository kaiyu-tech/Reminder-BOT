require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "successfully get new" do
    get new_session_path, params: { 'liff.state': "/#URL-fragment" }
    assert flash.empty?
    assert_response :success
    assert_template 'sessions/new'
  end

  test "successfully post create" do
    post sessions_path, params: { id_token: "id_token_admin", all: true }
    assert flash.empty?
    assert_response :success
    url = JSON.parse(response.body)['url']
    assert_equal events_url, url

    user_id = session[:user]['id']
    assert connected?
    assert_equal current_user_id, user_id
    assert_equal current_user, User.find_by(id: user_id)
    assert current_user_id?(user_id)
    assert current_user_admin?
    assert show_all_events?
    assert_equal current_user_events, Event.where(user_id: user_id)
  end

  test "failed to post create" do
    post sessions_path, params: { id_token: "null" }
    assert_not flash.empty?
    assert_response :success
    url = JSON.parse(response.body)['url']
    assert_equal destroy_sessions_url(type: :login), url
  end

  test "successfully get destroy" do
    post sessions_path, params: { id_token: "id_token_user_1" }

    get destroy_sessions_path(type: :close)
    assert flash.empty?
    assert_response :success
    assert_template 'sessions/terminate'
  end
end