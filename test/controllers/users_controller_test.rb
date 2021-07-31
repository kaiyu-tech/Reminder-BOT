require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:admin)
    @user_1 = users(:user_1)
    @other_user = users(:user_2)
  end

  ### connected_user

  test "successfully get index when connected" do
    connect_as("id_token_user_1")
    get users_path
    assert flash.empty?
    assert_response :success
    assert_template 'users/index'
  end

  test "failed to get index when not connected" do
    get users_path
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully edit user when connected" do
    connect_as("id_token_user_1")
    get edit_user_path(@user_1)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'
  end

  test "failed to edit user when not connected" do
    get edit_user_path(@user_1)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully update user when connected" do
    user_params = {
      user: {
        activate: true,
        notify_token: "notify_token" }}

    connect_as("id_token_user_1")
    patch user_path(@user_1), params: user_params
    assert_not flash.empty?
    assert_redirected_to edit_user_url(@user_1)
  end

  test "failed to update user when not connected" do
    user_params = {
      user: {
        activate: true,
        notify_token: "notify_token" }}

    patch user_path(@user_1), params: user_params
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  ### correct_user

  test "successfully edit user as admin" do
    connect_as("id_token_admin")
    get edit_user_path(@other_user)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'
  end

  test "successfully edit user as user" do
    connect_as("id_token_user_1")
    get edit_user_path(@user_1)
    assert flash.empty?
    assert_response :success
    assert_template 'users/edit'
  end

  test "failed to edit user as wrong user" do
    connect_as("id_token_user_1")
    get edit_user_path(@other_user)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully update user as admin" do
    user_params = {
      user: {
        activate: true,
        notify_token: "notify_token" }}

    connect_as("id_token_admin")
    patch user_path(@other_user), params: user_params
    assert_not flash.empty?
    assert_redirected_to edit_user_url(@other_user)
  end

  test "successfully update user as user" do
    user_params = {
      user: {
        activate: true,
        notify_token: "notify_token" }}

    connect_as("id_token_user_1")
    patch user_path(@user_1), params: user_params
    assert_not flash.empty?
    assert_redirected_to edit_user_url(@user_1)
  end

  test "failed to update user as wrong user" do
    user_params = {
      user: {
        activate: true,
        notify_token: "notify_token" }}

    connect_as("id_token_user_1")
    patch user_path(@other_user), params: user_params
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully destroy user as admin" do
    connect_as("id_token_admin")
    assert_difference 'User.count', -1 do
      delete user_path(@user_1)
    end
    assert_not flash.empty?
    assert_redirected_to users_url
  end

  test "failed to destroy admin as admin" do
    connect_as("id_token_admin")
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :operation)
  end

  test "successfully destroy user as user" do
    connect_as("id_token_user_1")
    assert_difference 'User.count', -1 do
      delete user_path(@user_1)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :close)
  end

  test "failed to destroy user as wrong user" do
    connect_as("id_token_user_1")
    assert_no_difference 'User.count' do
      delete user_path(@other_user)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end
end
