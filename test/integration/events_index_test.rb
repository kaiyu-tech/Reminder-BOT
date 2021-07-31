require 'test_helper'

class EventsIndexTest < ActionDispatch::IntegrationTest

  def setup
    @event_admin = events(:event_1)
    @event_user_1 = events(:event_2)
    @event_user_2 = events(:event_4)
  end

  test "pagination layout as admin" do
    connect_as("id_token_admin", true)
    get events_path
    assert_response :success
    assert_template 'events/index'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 1

    assert_select 'div.pagination'

    first_page_of_events = Event.paginate(page: 1)
    pagination_link_count = (2 + first_page_of_events.total_pages) * 2
    events_link_count = first_page_of_events.size
    delete_link_count = first_page_of_events.size

    assert_select 'a', count: header_link_count + footer_link_count +
                              button_link_count + pagination_link_count +
                              events_link_count + delete_link_count
  end

  test "pagination layout as user when data is empty" do
    Event.destroy_all

    connect_as("id_token_user_1", false)
    get events_path
    assert_response :success
    assert_template 'events/index'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 1

    assert_select 'div.pagination', false

    first_page_of_events = current_user_events.paginate(page: 1)
    pagination_link_count = 0
    events_link_count = first_page_of_events.size
    delete_link_count = first_page_of_events.size

    assert_select 'a', count: header_link_count + footer_link_count +
                              button_link_count + pagination_link_count +
                              events_link_count + delete_link_count
  end

  test "index page layout as admin" do
    connect_as("id_token_admin", true)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'

    assert_select 'div.pagination'
    first_page_of_events = Event.paginate(page: 1)
    first_page_of_events.each do |event|
      assert_select 'a[href=?]', edit_event_path(event), text: event.title
      assert_select 'span.line_name', /#{event.user.line_name}/
      assert_select 'span.description', event.description

      assert_select 'span.datetime', strip_tags(event.datetime_to_string.gsub(/\R/, "</br>").html_safe)

      next_reminder = event.reminders.where('remind_at > ?', Time.zone.now).order(remind_at: :asc).first
      event.reminders.order(remind_at: :asc).each do |reminder|
        assert_select "span.remind_at-#{reminder.id}", reminder.remind_time.inspect + (next_reminder.present? && reminder.remind_time == next_reminder.remind_time ? " [Next time]" : "")
      end

      assert_select 'span.timestamp', /#{time_ago_in_words(event.start_datetime)}/

      assert_select 'a[href=?]', event_path(event), text: 'delete'
    end
  end

  test "index page layout as user" do
    connect_as("id_token_user_1", false)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'

    assert_select 'div.pagination'
    first_page_of_events = current_user_events.paginate(page: 1)
    first_page_of_events.each do |event|
      assert_select 'a[href=?]', edit_event_path(event), text: event.title
      assert_select 'span.line_name', count: 0
      assert_select 'span.description', event.description

      assert_select 'span.datetime', strip_tags(event.datetime_to_string.gsub(/\R/, "</br>").html_safe)

      next_reminder = event.reminders.where('remind_at > ?', Time.zone.now).order(remind_at: :asc).first
      event.reminders.order(remind_at: :asc).each do |reminder|
        assert_select "span.remind_at-#{reminder.id}", reminder.remind_time.inspect + (next_reminder.present? && reminder.remind_time == next_reminder.remind_time ? " [Next time]" : "")
      end

      assert_select 'span.timestamp', /#{time_ago_in_words(event.start_datetime)}/

      assert_select 'a[href=?]', event_path(event), text: 'delete'
    end
  end

  test "delete event as admin" do
    connect_as("id_token_admin", true)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'
    assert_difference 'Event.count', -1 do
      delete event_path(@event_user_1)
    end
    assert_not flash.empty?
    assert_redirected_to events_url

    connect_as("id_token_admin", true)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'
    assert_difference 'Event.count', -1 do
      delete event_path(@event_user_2)
    end
    assert_not flash.empty?
    assert_redirected_to events_url

    connect_as("id_token_admin", true)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'
    assert_difference 'Event.count', -1 do
      delete event_path(@event_admin)
    end
    assert_not flash.empty?
    assert_redirected_to events_url
  end

  test "delete event as user" do
    connect_as("id_token_user_1", false)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'
    assert_difference 'Event.count', -1 do
      delete event_path(@event_user_1)
    end
    assert_not flash.empty?
    assert_redirected_to events_url

    connect_as("id_token_user_1", false)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'
    assert_no_difference 'Event.count' do
      delete event_path(@event_user_2)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)

    connect_as("id_token_user_1", false)
    get JSON.parse(response.body)['url']
    assert_response :success
    assert_template 'events/index'
    assert_no_difference 'Event.count' do
      delete event_path(@event_admin)
    end
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "page transition as admin" do
    connect_as("id_token_admin", true)
    get events_path
    assert_select 'a[href=?]', edit_event_path(@event_user_1), text: @event_user_1.title
    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    connect_as("id_token_admin", true)
    get events_path
    assert_select 'a[href=?]', edit_event_path(@event_user_2), text: @event_user_2.title
    get edit_event_path(@event_user_2)
    assert_response :success
    assert_template 'events/edit'

    connect_as("id_token_admin", true)
    get events_path
    assert_select 'a[href=?]', edit_event_path(@event_admin), text: @event_admin.title
    get edit_event_path(@event_admin)
    assert_response :success
    assert_template 'events/edit'
  end

  test "page transition as user" do
    connect_as("id_token_user_1", false)
    get events_path
    assert_select 'a[href=?]', edit_event_path(@event_user_1), text: @event_user_1.title
    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    connect_as("id_token_user_1", true)
    get events_path
    assert_select 'a[href=?]', edit_event_path(@event_user_2), text: @event_user_2.title, count: 0
    get edit_event_path(@event_user_2)
    assert_redirected_to destroy_sessions_url(type: :session)

    connect_as("id_token_user_1", true)
    get events_path
    assert_select 'a[href=?]', edit_event_path(@event_admin), text: @event_admin.title, count: 0
    get edit_event_path(@event_admin)
    assert_redirected_to destroy_sessions_url(type: :session)
  end
end
