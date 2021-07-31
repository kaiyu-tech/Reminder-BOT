require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:admin)
    @user_1 = users(:user_1)
    @user_2 = users(:user_2)
  end

  test "pagination layout as admin" do
    connect_as("id_token_admin")
    get users_path
    assert_response :success
    assert_template 'users/index'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 0

    assert_select 'div.pagination'

    first_page_of_users = User.paginate(page: 1)
    pagination_link_count = (2 + first_page_of_users.total_pages) * 2
    users_link_count = first_page_of_users.size
    delete_link_count = first_page_of_users.select{ |n| not(n.admin?) }.size

    assert_select 'a', count: header_link_count + footer_link_count +
                              button_link_count + pagination_link_count +
                              users_link_count + delete_link_count
  end

  test "pagination layout as user when data is empty" do
    Event.destroy_all

    connect_as("id_token_user_1")
    get users_path
    assert_response :success
    assert_template 'users/index'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 0

    assert_select 'div.pagination', false

    first_page_of_users = User.where(id: current_user_id).paginate(page: 1)
    pagination_link_count = 0
    users_link_count = first_page_of_users.size
    delete_link_count = first_page_of_users.select{ |n| not(n.admin?) }.size

    assert_select 'a', count: header_link_count + footer_link_count +
                              button_link_count + pagination_link_count +
                              users_link_count + delete_link_count
  end

  test "index page layout as admin" do
    connect_as("id_token_admin")
    get users_path
    assert_response :success
    assert_template 'users/index'

    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', edit_user_path(user), text: user.line_name
      assert_select 'span.notify_token', /#{user.notify_token&.truncate(20)}/
      assert_select 'span.expires_in', /#{I18n.l(user.expires_in)}/ if user.expires_in.present?
      assert_select 'span.timestamp', user.reminded_at.present? ? /#{time_ago_in_words(user.reminded_at)}/ : /Never been reminded./
      assert_select "a[href=?]", user_path(user), text: 'delete', count: user.admin? ? 0 : 1
    end
  end

  test "index page layout as user" do
    connect_as("id_token_user_1")
    get users_path
    assert_response :success
    assert_template 'users/index'

    assert_select 'div.pagination', false
    first_page_of_users = User.where(id: current_user_id).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', edit_user_path(user), text: user.line_name
      assert_select 'span.notify_token', /#{user.notify_token&.truncate(20)}/
      assert_select 'span.expires_in', /#{I18n.l(user.expires_in)}/ if user.expires_in.present?
      assert_select 'span.timestamp', user.reminded_at.present? ? /#{time_ago_in_words(user.reminded_at)}/ : /Never been reminded./
      assert_select 'a[href=?]', user_path(user), text: 'delete'
    end
  end

  test "delete event as admin" do
    connect_as("id_token_admin")
    get users_path
    assert_difference 'User.count', -1 do
      delete user_path(@user_1)
    end
    assert_not flash.empty?
    assert_redirected_to users_url

    connect_as("id_token_admin")
    get users_path
    assert_difference 'User.count', -1 do
      delete user_path(@user_2)
    end
    assert_not flash.empty?
    assert_redirected_to users_url

    connect_as("id_token_admin")
    get users_path
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :operation)
  end

  test "delete event as user" do
    connect_as("id_token_user_1")
    get users_path
    assert_difference 'User.count', -1 do
      delete user_path(@user_1)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :close)

    connect_as("id_token_user_1")
    get users_path
    assert_no_difference 'User.count' do
      delete user_path(@user_2)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)

    connect_as("id_token_user_1")
    get users_path
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "page transition as admin" do
    connect_as("id_token_admin")
    get users_path
    assert_select 'a[href=?]', edit_user_path(@user_1), text: @user_1.line_name
    get edit_user_path(@user_1)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'

    connect_as("id_token_admin")
    get users_path
    assert_select 'a[href=?]', edit_user_path(@user_2), text: @user_2.line_name
    get edit_user_path(@user_2)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'

    connect_as("id_token_admin")
    get users_path
    assert_select 'a[href=?]', edit_user_path(@admin), text: @admin.line_name
    get edit_user_path(@admin)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'
  end

  test "page transition as user" do
    connect_as("id_token_user_1")
    get users_path
    assert_select 'a[href=?]', edit_user_path(@user_1), text: @user_1.line_name
    get edit_user_path(@user_1)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'

    connect_as("id_token_user_1")
    get users_path
    assert_select 'a[href=?]', edit_user_path(@user_2), text: @user_2.line_name, count: 0
    get edit_user_path(@user_2)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)

    connect_as("id_token_user_1")
    get users_path
    assert_select 'a[href=?]', edit_user_path(@admin), text: @admin.line_name, count: 0
    get edit_user_path(@admin)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end
end