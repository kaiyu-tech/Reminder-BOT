require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest

  def setup
    travel_to("2021-06-16 12:00:00 +0900")

    @admin = users(:admin)
    @user_1 = users(:user_1)
    @other_user = users(:user_2)
  end

  ### connected_user

  test "successfully get index when connected" do
    connect_as("id_token_user_1")
    get events_path
    assert_response :success
    assert_template 'events/index'
  end

  test "failed to get index when not connected" do
    get events_path
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully get new when connected" do
    connect_as("id_token_user_1")
    get new_event_path
    assert_response :success
    assert_template 'events/new'
  end

  test "failed to get new when not connected" do
    get new_event_path
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully create event when connected" do
    @user_1.events.destroy_all
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { number: 10, unit: 1 },
          '1': { number: 1, unit: 2 },
          '2': { number: 1, unit: 3 }}}}

    connect_as("id_token_user_1")
    assert_difference 'Event.count', 1 do
      post events_path, params: event_params
    end
    assert_not flash.empty?
    @user_1.reload
    assert_redirected_to edit_event_url(@user_1.events.first)
  end

  test "failed to create event when not connected" do
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { number: 10, unit: 1 },
          '1': { number: 1, unit: 2 },
          '2': { number: 1, unit: 3 }}}}

    post events_path, params: event_params
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully edit event when connected" do
    event = @user_1.events.first

    connect_as("id_token_user_1")
    get edit_event_path(event)
    assert_response :success
    assert_template 'events/edit'
  end

  test "failed to edit event when not connected" do
    event = @user_1.events.first

    get edit_event_path(event)
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully update event when connected" do
    event = @user_1.events.first
    reminders = event.reminders
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 10, unit: 1 },
          '1': { id: reminders[1].id, number: 1, unit: 2 },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    connect_as("id_token_user_1")
    patch event_path(event), params: event_params
    assert_not flash.empty?
    assert_redirected_to edit_event_url(event)
  end

  test "failed to update event when not connected" do
    event = @user_1.events.first
    reminders = event.reminders
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 10, unit: 1 },
          '1': { id: reminders[1].id, number: 1, unit: 2 },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    patch event_path(event), params: event_params
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully destroy event when connected" do
    event = @user_1.events.first

    connect_as("id_token_user_1")
    assert_difference 'Event.count', -1 do
      delete event_path(event)
    end
    assert_not flash.empty?
    assert_redirected_to events_url
  end

  test "failed to destroy event when not connected" do
    event = @user_1.events.first

    assert_no_difference 'Event.count' do
      delete event_path(event)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  ### correct_user

  test "successfully edit event as admin" do
    event = @user_1.events.first

    connect_as("id_token_admin")
    get edit_event_path(event)
    assert flash.empty?
    assert_response :success
    assert_template 'events/edit'
  end

  test "successfully edit event as user" do
    event = @user_1.events.first

    connect_as("id_token_user_1")
    get edit_event_path(event)
    assert flash.empty?
    assert_response :success
    assert_template 'events/edit'
  end

  test "failed to edit event as wrong user" do
    event = @other_user.events.first

    connect_as("id_token_user_1")
    get edit_event_path(event)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully update event as admin" do
    event = @user_1.events.first
    reminders = event.reminders
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 10, unit: 1 },
          '1': { id: reminders[1].id, number: 1, unit: 2 },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    connect_as("id_token_admin")
    patch event_path(event), params: event_params
    assert_not flash.empty?
    assert_redirected_to edit_event_url(event)
  end

  test "successfully update event as user" do
    event = @user_1.events.first
    reminders = event.reminders
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 10, unit: 1 },
          '1': { id: reminders[1].id, number: 1, unit: 2 },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    connect_as("id_token_user_1")
    patch event_path(event), params: event_params
    assert_not flash.empty?
    assert_redirected_to edit_event_url(event)
  end

  test "failed to update event as wrong user" do
    event = @other_user.events.first
    reminders = event.reminders
    event_params = {
      event_form: {
        title: "title",
        description: "description",
        start_date: "2021-06-16",
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 10, unit: 1 },
          '1': { id: reminders[1].id, number: 1, unit: 2 },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    connect_as("id_token_user_1")
    patch event_path(event), params: event_params
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "successfully destroy event as admin" do
    event = @user_1.events.first

    connect_as("id_token_admin")
    assert_difference 'Event.count', -1 do
      delete event_path(event)
    end
    assert_not flash.empty?
    assert_redirected_to events_url
  end

  test "successfully destroy event as user" do
    event = @user_1.events.first

    connect_as("id_token_user_1")
    assert_difference 'Event.count', -1 do
      delete event_path(event)
    end
    assert_not flash.empty?
    assert_redirected_to events_url
  end

  test "failed to destroy event as wrong user" do
    event = @other_user.events.first

    connect_as("id_token_user_1")
    assert_no_difference 'Event.count' do
      delete event_path(event)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end
end
