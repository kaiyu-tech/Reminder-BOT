require 'test_helper'

class EventsNewTest < ActionDispatch::IntegrationTest

  def setup
  end

  test "new page layout as user" do
    connect_as("id_token_user_1")
    get new_event_path
    assert_response :success
    assert_template 'events/new'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 1

    assert_select 'a', count: header_link_count + footer_link_count + button_link_count
    assert_select 'input.form-control', count: 9
    assert_select 'select', count: 7
    assert_select 'input.btn-success', count: 1
  end

  test "new event as user when data is invalid" do
    connect_as("id_token_user_1")
    get new_event_path
    assert_no_difference 'Event.count' do
      post events_path, params: {
        event_form: {
          title: "",
          description: "invalid",
          start_date: "2022-01-01",
          start_time: "00:00:00 +0900",
          reminders_attributes: {
            '0': { number: 30, unit: 1 },
            '1': { number: 1, unit: 2 },
            '2': { number: 1, unit: 3 }}}}
    end
    assert_not flash.empty?
    assert_response :success
    assert_template 'events/new'
  end

  test "new event as user when data is valid" do
    connect_as("id_token_user_1")
    get new_event_path
    assert_difference 'Event.count', 1 do
      post events_path, params: {
        event_form: {
          title: "title",
          description: "valid",
          start_date: "2022-01-01",
          start_time: "00:00:00 +0900",
          reminders_attributes: {
            '0': { number: 30, unit: 1 },
            '1': { number: 1, unit: 2 },
            '2': { number: 1, unit: 3 }}}}
    end
    follow_redirect!
    assert_not flash.empty?
    assert_response :success
    assert_template 'events/edit'
  end
end
