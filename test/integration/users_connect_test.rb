require 'test_helper'

class UsersConnectTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:admin)
    @user = users(:user_1)
    @other_user = users(:user_2)
  end

  test "successfully connected with admin who is logged in to LINE when all is true" do
    get new_session_path, params: { 'liff.state': "/?all=true#URL-fragment" }
    assert_not connected?
    assert_template 'sessions/new'
    assert_select "h3", "Loading ..."

    # If the user is logged in to LINE.
    post sessions_path, params: { id_token: "id_token_admin", all: true }
    assert_response :success
    assert connected?
    assert User.find_by(id: current_user_id).compare?("line_id_admin")
    assert show_all_events?

    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'

    assert_select "a[href=?]", new_event_path
    assert_select "a[href=?]", edit_event_path(@admin.events.first), text: @admin.events.first.title
    assert_select "a[href=?]", event_path(@admin.events.first), text: 'delete'
    assert_select "a[href=?]", edit_event_path(@other_user.events.first), text: @other_user.events.first.title
    assert_select "a[href=?]", event_path(@other_user.events.first), text: 'delete'
    assert_select "a[href=?]", destroy_sessions_path(type: :close)

    get destroy_sessions_path(type: :close)
    assert_not connected?
    assert_select "h3", "Please close window."
  end

  test "failed to connect as user who is not logged in to LINE" do
    get new_session_path, params: { 'liff.state': "/#URL-fragment" }
    assert_not connected?
    assert_template 'sessions/new'
    assert_select "h3", "Loading ..."

    # If the user is not logged in to LINE.
    post sessions_path, params: { id_token: "null" }
    assert_response :success
    assert_not connected?

    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'sessions/terminate'

    assert_select "h3", "Please register."
  end

  test "successfully connected with user who is logged in to LINE" do
    get new_session_path, params: { 'liff.state': "/#URL-fragment" }
    assert_not connected?
    assert_template 'sessions/new'
    assert_select "h3", "Loading ..."

    # If the user is logged in to LINE.
    post sessions_path, params: { id_token: "id_token_user_1" }
    assert_response :success
    assert connected?
    assert User.find_by(id: current_user_id).compare?("line_id_user_1")
    assert_not show_all_events?

    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'

    assert_select "a[href=?]", new_event_path
    assert_select "a[href=?]", edit_event_path(@user.events.first), text: @user.events.first.title
    assert_select "a[href=?]", event_path(@user.events.first), text: 'delete'
    assert_select "a[href=?]", edit_event_path(@other_user.events.first), text: @other_user.events.first.title, count: 0
    assert_select "a[href=?]", event_path(@other_user.events.first), text: 'delete', count: 0
    assert_select "a[href=?]", destroy_sessions_path(type: :close)

    get destroy_sessions_path(type: :close)
    assert_not connected?
    assert_select "h3", "Please close window."
  end

  test "successfully connected with user who is logged in to LINE when all is true" do
    get new_session_path, params: { 'liff.state': "/#URL-fragment" }
    assert_not connected?
    assert_template 'sessions/new'
    assert_select "h3", "Loading ..."

    # If the user is logged in to LINE.
    post sessions_path, params: { id_token: "id_token_user_1", all: true }
    assert connected?
    assert User.find_by(id: current_user_id).compare?("line_id_user_1")
    assert_not show_all_events? # It is correct that the "ALL flag" is ignored.
  end
end