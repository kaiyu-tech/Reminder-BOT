require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:admin)
    @user_1 = users(:user_1)
    @user_2 = users(:user_2)
  end

  test "edit page as admin" do
    connect_as("id_token_admin")

    get edit_user_path(@admin)
    assert_response :success
    assert_template 'users/edit'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 1

    assert_select 'a', count: header_link_count + footer_link_count + button_link_count
    assert_select 'input.form-control', count: 4
    assert_select 'input.btn-success', count: 1

    assert_select 'a[href=?]', users_path, text: "Back"
    assert_select 'input#user_line_name[type=text][disabled=disabled]', value: @user_1.line_name
    assert_select 'input#user_activate[type=checkbox]', checked: @user_1.activate
    assert_select 'input#user_notify_token[type=text]', value: @user_1.notify_token
    assert_select 'input#user_expires_in[type=datetime-local]', value: @user_1.expires_in
    assert_select 'input#user_reminded_at[type=datetime-local][disabled=disabled]', value: @user_1.reminded_at
    assert_select 'input.btn-success[type=submit]', value: "Save changes"

    get edit_user_path(@user_1)
    assert_response :success
    assert_template 'users/edit'

    assert_select 'a[href=?]', users_path, text: "Back"
    assert_select 'input#user_line_name[type=text][disabled=disabled]', value: @user_2.line_name
    assert_select 'input#user_activate[type=checkbox]', checked: @user_2.activate
    assert_select 'input#user_notify_token[type=text]', value: @user_2.notify_token
    assert_select 'input#user_expires_in[type=datetime-local]', value: @user_2.expires_in
    assert_select 'input#user_reminded_at[type=datetime-local][disabled=disabled]', value: @user_2.reminded_at
    assert_select 'input.btn-success[type=submit]', value: "Save changes"
  end

  test "edit page layout as user" do
    connect_as("id_token_user_1")

    get edit_user_path(@user_1)
    assert_response :success
    assert_template 'users/edit'

    assert_select 'a[href=?]', users_path, text: "Back"
    assert_select 'input#user_line_name[type=text][disabled=disabled]', value: @user_1.line_name
    assert_select 'input#user_activate[type=checkbox]', checked: @user_1.activate
    assert_select 'input#user_notify_token[type=text]', value: @user_1.notify_token
    assert_select 'input#user_expires_in[type=datetime-local]', value: @user_1.expires_in
    assert_select 'input#user_reminded_at[type=datetime-local][disabled=disabled]', value: @user_1.reminded_at
    assert_select 'input.btn-success[type=submit]', value: "Save changes"

    get edit_user_path(@user_2)
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "edit event as admin when event data is invalid" do
    connect_as("id_token_admin") # No difference by operator.

    get edit_user_path(@admin)
    assert_response :success
    assert_template 'users/edit'

    notify_token = "x" * 256 # invalid
    patch user_path(@admin), params: {
        user: {
          activate: @admin.activate,
          notify_token: notify_token, # invalid
          expires_in: @admin.expires_in
        }}

    assert_not flash.empty?
    assert_response :success
    assert_template 'users/edit'
    @admin.reload
    assert_not_equal notify_token, @admin.notify_token

    get edit_user_path(@user_1)
    assert_response :success
    assert_template 'users/edit'

    activate = nil # invalid
    notify_token = "notify_token_dummy"
    expires_in = "2021-12-31 23:59:59 +09:00".in_time_zone
    patch user_path(@user_1), params: {
        user: {
          activate: activate, # invalid
          notify_token: notify_token,
          expires_in: expires_in
        }}

    assert_not flash.empty?
    assert_response :success
    assert_template 'users/edit'
    @user_1.reload
    assert_not_equal activate, @user_1.activate?
    assert_not_equal notify_token, @user_1.notify_token
    assert_not_equal expires_in, @user_1.expires_in
  end

  test "edit event as admin when event data is valid" do
    connect_as("id_token_admin")

    get edit_user_path(@admin)
    assert_response :success
    assert_template 'users/edit'

    notify_token = "notify_token_dummy"
    patch user_path(@admin), params: {
        user: {
          activate: @admin.activate,
          notify_token: notify_token,
          expires_in: @admin.expires_in
        }}

    assert_not flash.empty?
    assert_redirected_to edit_user_url(@admin)
    @admin.reload
    assert_equal notify_token, @admin.notify_token

    get edit_user_path(@user_1)
    assert_response :success
    assert_template 'users/edit'

    activate = false
    notify_token = "notify_token_dummy"
    expires_in = nil
    patch user_path(@user_1), params: {
        user: {
          activate: activate,
          notify_token: notify_token,
          expires_in: expires_in
        }}

    assert_not flash.empty?
    assert_redirected_to edit_user_url(@user_1)
    @user_1.reload
    assert_equal activate, @user_1.activate?
    assert_equal notify_token, @user_1.notify_token
    assert_nil @user_1.expires_in
  end

  test "edit event as user when data is valid" do
    connect_as("id_token_user_1")

    get edit_user_path(@user_1)
    assert_response :success
    assert_template 'users/edit'

    notify_token = "notify_token_dummy"
    patch user_path(@user_1), params: {
        user: {
          activate: @user_1.activate,
          notify_token: notify_token,
          expires_in: @user_1.expires_in
        }}

    assert_not flash.empty?
    assert_redirected_to edit_user_url(@user_1)
    @user_1.reload
    assert_equal notify_token, @user_1.notify_token

    get edit_user_path(@user_2)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "edit event as admin when data is inaccessible" do
    connect_as("id_token_admin")

    get edit_user_path(@admin)
    assert_response :success
    assert_template 'users/edit'

    activate = false
    expires_in = "2021-12-31 23:59:59 +09:00".in_time_zone
    patch user_path(@admin), params: {
        user: {
          activate: activate,
          notify_token: @admin.notify_token,
          expires_in: expires_in
        }}

    assert_not flash.empty?
    assert_redirected_to edit_user_url(@admin)
    @admin.reload
    assert_not_equal activate, @admin.activate?
    assert_not_equal expires_in, @admin.expires_in
  end

  test "edit event as user when data is inaccessible" do
    connect_as("id_token_user_1")

    get edit_user_path(@user_1)
    assert_response :success
    assert_template 'users/edit'

    activate = false
    expires_in = "2021-12-31 23:59:59 +09:00".in_time_zone
    patch user_path(@user_1), params: {
        user: {
          activate: activate,
          notify_token: @user_1.notify_token,
          expires_in: expires_in
        }}

    assert_not flash.empty?
    assert_redirected_to edit_user_url(@user_1)
    @user_1.reload
    assert_not_equal activate, @user_1.activate?
    assert_not_equal expires_in, @user_1.expires_in
  end
end
