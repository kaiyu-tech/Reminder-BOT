require 'test_helper'

class EventsEditTest < ActionDispatch::IntegrationTest

  def setup
    travel_to("2021-06-16 12:00:00 +0900")

    @event_admin = events(:event_1)
    @event_user_1 = events(:event_2)
    @event_user_2 = events(:event_4)
  end

  test "edit page layout as admin" do
    connect_as("id_token_admin")

    get edit_event_path(@event_admin)
    assert_response :success
    assert_template 'events/edit'

    header_link_count = 3
    footer_link_count = 2
    button_link_count = 1

    assert_select 'a', count: header_link_count + footer_link_count + button_link_count
    assert_select 'input.form-control', count: 9
    assert_select 'select', count: 7
    assert_select 'input.btn-success', count: 1

    assert_select 'input#event_form_title', value: @event_admin.title
    assert_select 'input#event_form_description', value: @event_admin.description
    assert_select 'input#event_form_start_date', value: @event_admin.start_date
    assert_select 'input#event_form_end_date', value: @event_admin.end_date
    assert_select 'input#event_form_start_time', value: @event_admin.start_time
    assert_select 'input#event_form_end_time', value: @event_admin.end_time
    assert_select 'select#event_form_day_of_week', value: @event_admin.day_of_week
    assert_select 'select#event_form_with_order', value: @event_admin.with_order
    assert_select 'select#event_form_week_of_month', value: @event_admin.week_of_month
    assert_select 'select#event_form_day_of_month', value: @event_admin.day_of_month
    assert_select 'input#event_form_reminders_attributes_0_number', value: @event_admin.reminders[0].number
    assert_select 'select#event_form_reminders_attributes_0_unit', value: @event_admin.reminders[0].unit
    assert_select 'input#event_form_reminders_attributes_1_number', value: @event_admin.reminders[1].number
    assert_select 'select#event_form_reminders_attributes_1_unit', value: @event_admin.reminders[1].unit
    assert_select 'input#event_form_reminders_attributes_2_number', value: @event_admin.reminders[2].number
    assert_select 'select#event_form_reminders_attributes_2_unit', value: @event_admin.reminders[2].unit
    assert_select 'input.btn-success[type=submit]', value: "Create event"

    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    assert_select 'input#event_form_title', value: @event_user_1.title
    assert_select 'input#event_form_description', value: @event_user_1.description
    assert_select 'input#event_form_start_date', value: @event_user_1.start_date
    assert_select 'input#event_form_end_date', value: @event_user_1.end_date
    assert_select 'input#event_form_start_time', value: @event_user_1.start_time
    assert_select 'input#event_form_end_time', value: @event_user_1.end_time
    assert_select 'select#event_form_day_of_week', value: @event_user_1.day_of_week
    assert_select 'select#event_form_with_order', value: @event_user_1.with_order
    assert_select 'select#event_form_week_of_month', value: @event_user_1.week_of_month
    assert_select 'select#event_form_day_of_month', value: @event_user_1.day_of_month
    assert_select 'input#event_form_reminders_attributes_0_number', value: @event_user_1.reminders[0].number
    assert_select 'select#event_form_reminders_attributes_0_unit', value: @event_user_1.reminders[0].unit
    assert_select 'input#event_form_reminders_attributes_1_number', value: @event_user_1.reminders[1].number
    assert_select 'select#event_form_reminders_attributes_1_unit', value: @event_user_1.reminders[1].unit
    assert_select 'input#event_form_reminders_attributes_2_number', value: @event_user_1.reminders[2].number
    assert_select 'select#event_form_reminders_attributes_2_unit', value: @event_user_1.reminders[2].unit
    assert_select 'input.btn-success[type=submit]', value: "Create event"
  end

  test "edit page layout as user" do
    connect_as("id_token_user_1")

    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    assert_select 'input#event_form_title', value: @event_user_1.title
    assert_select 'input#event_form_description', value: @event_user_1.description
    assert_select 'input#event_form_start_date', value: @event_user_1.start_date
    assert_select 'input#event_form_end_date', value: @event_user_1.end_date
    assert_select 'input#event_form_start_time', value: @event_user_1.start_time
    assert_select 'input#event_form_end_time', value: @event_user_1.end_time
    assert_select 'select#event_form_day_of_week', value: @event_user_1.day_of_week
    assert_select 'select#event_form_with_order', value: @event_user_1.with_order
    assert_select 'select#event_form_week_of_month', value: @event_user_1.week_of_month
    assert_select 'select#event_form_day_of_month', value: @event_user_1.day_of_month
    assert_select 'input#event_form_reminders_attributes_0_number', value: @event_user_1.reminders[0].number
    assert_select 'select#event_form_reminders_attributes_0_unit', value: @event_user_1.reminders[0].unit
    assert_select 'input#event_form_reminders_attributes_1_number', value: @event_user_1.reminders[1].number
    assert_select 'select#event_form_reminders_attributes_1_unit', value: @event_user_1.reminders[1].unit
    assert_select 'input#event_form_reminders_attributes_2_number', value: @event_user_1.reminders[2].number
    assert_select 'select#event_form_reminders_attributes_2_unit', value: @event_user_1.reminders[2].unit
    assert_select 'input.btn-success[type=submit]', value: "Create event"

    get edit_event_path(@event_user_2)
    assert_redirected_to destroy_sessions_url(type: :session)
  end

  test "edit event as user when event data is invalid" do
    connect_as("id_token_user_1")

    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    reminders = @event_user_1.reminders
    title  = "" # invalid
    description = "description"
    start_date = "2021-06-17".to_date
    number  = 2
    unit = 3
    reminder_id = reminders[1].id
    patch event_path(@event_user_1), params: {
      event_form: {
        title: title, # invalid
        description: description,
        start_date: start_date,
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 30, unit: 1 },
          '1': { id: reminders[1].id, number: number, unit: unit },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    assert_not flash.empty?
    assert_response :success
    assert_template 'events/edit'

    @event_user_1.reload
    assert_not_equal title, @event_user_1.title
    assert_not_equal description, @event_user_1.description
    assert_not_equal start_date, @event_user_1.start_date
    assert_not_equal number, @event_user_1.reminders.find(reminder_id).number
    assert_not_equal unit, @event_user_1.reminders.find(reminder_id).unit
  end

  test "edit event as user when reminder data is invalid" do
    connect_as("id_token_user_1")

    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    reminders = @event_user_1.reminders
    title  = "title"
    description = "description"
    start_date = "2021-06-17".to_date
    number  = nil # invalid
    unit = nil # invalid
    reminder_id = reminders[1].id
    patch event_path(@event_user_1), params: {
      event_form: {
        title: title,
        description: description,
        start_date: start_date,
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 30, unit: 1 },
          '1': { id: reminders[1].id, number: number, unit: unit }, # invalid
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    assert_not flash.empty?
    assert_response :success
    assert_template 'events/edit'

    @event_user_1.reload
    assert_not_equal title, @event_user_1.title
    assert_not_equal description, @event_user_1.description
    assert_not_equal start_date, @event_user_1.start_date
    assert_not_equal number, @event_user_1.reminders.find(reminder_id).number
    assert_not_equal unit, @event_user_1.reminders.find(reminder_id).unit
  end

  test "edit event as admin when data is valid" do
    connect_as("id_token_admin")

    get edit_event_path(@event_admin)
    assert_response :success
    assert_template 'events/edit'

    reminders = @event_admin.reminders
    title  = "title"
    description = "description"
    start_date = "2021-06-17".to_date
    number  = 2
    unit = 3
    reminder_id = reminders[1].id
    patch event_path(@event_admin), params: {
      event_form: {
        title: title,
        description: description,
        start_date: start_date,
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 30, unit: 1 },
          '1': { id: reminders[1].id, number: number, unit: unit },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    assert_not flash.empty?
    assert_redirected_to edit_event_url(@event_admin)
    @event_admin.reload
    assert_equal title, @event_admin.title
    assert_equal description, @event_admin.description
    assert_equal start_date, @event_admin.start_date
    assert_equal number, @event_admin.reminders.find(reminder_id).number
    assert_equal unit, @event_admin.reminders.find(reminder_id).unit

    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    reminders = @event_user_1.reminders
    title  = "title"
    description = "description"
    start_date = "2021-06-17".to_date
    number  = 2
    unit = 3
    reminder_id = reminders[1].id
    patch event_path(@event_user_1), params: {
      event_form: {
        title: title,
        description: description,
        start_date: start_date,
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 30, unit: 1 },
          '1': { id: reminders[1].id, number: number, unit: unit },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    assert_not flash.empty?
    assert_redirected_to edit_event_url(@event_user_1)
    @event_user_1.reload
    assert_equal title, @event_user_1.title
    assert_equal description, @event_user_1.description
    assert_equal start_date, @event_user_1.start_date
    assert_equal number, @event_user_1.reminders.find(reminder_id).number
    assert_equal unit, @event_user_1.reminders.find(reminder_id).unit
  end

  test "edit event as user when data is valid" do
    connect_as("id_token_user_1")

    get edit_event_path(@event_user_1)
    assert_response :success
    assert_template 'events/edit'

    reminders = @event_user_1.reminders
    title  = "title"
    description = "description"
    start_date = "2021-06-17".to_date
    number  = 2
    unit = 3
    reminder_id = reminders[1].id
    patch event_path(@event_user_1), params: {
      event_form: {
        title: title,
        description: description,
        start_date: start_date,
        reminders_attributes: {
          '0': { id: reminders[0].id, number: 30, unit: 1 },
          '1': { id: reminders[1].id, number: number, unit: unit },
          '2': { id: reminders[2].id, number: 1, unit: 3 }}}}

    assert_not flash.empty?
    assert_redirected_to edit_event_url(@event_user_1)
    @event_user_1.reload
    assert_equal title, @event_user_1.title
    assert_equal description, @event_user_1.description
    assert_equal start_date, @event_user_1.start_date
    assert_equal number, @event_user_1.reminders.find(reminder_id).number
    assert_equal unit, @event_user_1.reminders.find(reminder_id).unit

    get edit_event_path(@event_user_2)
    assert_not flash.empty?
    assert_redirected_to destroy_sessions_url(type: :session)
  end
end
