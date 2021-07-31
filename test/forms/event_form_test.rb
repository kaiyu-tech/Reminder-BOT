require 'test_helper'

class EventFormTest < ActiveJob::TestCase

  def setup
    travel_to("2021-06-16 12:00:00 +0900")

    @user = users(:user_1)
    @event = @user.events.build(title: "title",
                                description: "description",
                                start_date: nil,
                                end_date: nil,
                                start_time: nil,
                                end_time: nil,
                                day_of_week: nil,
                                with_order: nil,
                                week_of_month: nil,
                                day_of_month: nil,
                                start_datetime: nil,
                                end_datetime: nil)

    @event_2 = events(:event_2)
    @reminder = @event_2.reminders.build(number: 10, unit: 1, remind_at: nil)
  end

  ### event

  test "should be valid" do
    @event.start_date = "2021-06-16"
    @event_form = EventForm.new(@event)
    assert @event_form.valid?
  end

    test "user id should be present" do
    @event.user_id = nil
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "title should be present" do
    @event.start_date = "2021-06-16"
    @event.title = "     "
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "title should not be too long" do
    @event.start_date = "2021-06-16"
    @event.title = "x" * 31
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "description should not be too long" do
    @event.start_date = "2021-06-16"
    @event.description = "x" * 121
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "date validation" do
    # should accept valid value
    @event.start_date = "2021-06-16"
    @event.end_date = "2021-06-17"
    @event_form = EventForm.new(@event)
    assert @event_form.valid?

    # reject invalid value
    @event.start_date = "2021-06-15"
    @event.end_date = nil
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_date = "2021-06-17"
    @event.end_date = "2021-06-16"
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_date = nil
    @event.end_date = "2021-06-16"
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_date = nil
    @event.day_of_week = nil
    @event.with_order = nil
    @event.week_of_month = nil
    @event.day_of_month = nil
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_date = "2021-06-16"
    @event.day_of_week = 1
    @event.day_of_month = nil
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_date = "2021-06-16"
    @event.day_of_week = nil
    @event.day_of_month = 1
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "time validation" do
    # should accept valid value
    @event.start_time = "0:00:00 +0900"
    @event.end_time = "1:00:00 +0900"
    @event_form = EventForm.new(@event)
    assert @event_form.valid?

    # reject invalid value
    @event.start_time = "1:00:00 +0900"
    @event.end_time = "0:00:00 +0900"
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_time = nil
    @event.end_time = "0:00:00 +0900"
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?

    @event.start_time = nil
    @event.day_of_week = nil
    @event.with_order = nil
    @event.week_of_month = nil
    @event.day_of_month = nil
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "'day of week' validation" do
    # should accept valid value
    valid_values = [*0..6]
    valid_values.each do |valid_value|
      @event.day_of_week = valid_value
      @event_form = EventForm.new(@event)
      assert @event_form.valid?, "#{valid_value.inspect} should be valid"
    end

    # reject invalid value
    invalid_values = [-1,7,nil]
    invalid_values.each do |invalid_value|
      @event.day_of_week = invalid_value
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value.inspect} should be invalid"
    end

    @event.day_of_week = 1
    @event.day_of_month = 1
    @event_form = EventForm.new(@event)
    assert_not @event_form.valid?
  end

  test "'day of week' and 'with order' validation" do
    # should accept valid value
    valid_values1 = [*0..6]
    valid_values2 = [*1..5]

    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @event.day_of_week = valid_value1
      @event.with_order = valid_value2
      @event_form = EventForm.new(@event)
      assert @event_form.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end

    # reject invalid value
    invalid_values1 = [*0..6]
    invalid_values2 = [-1,0,6]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.with_order = invalid_value2
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end

    invalid_values1 = [-1,7,nil]
    invalid_values2 = [*1..5]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.with_order = invalid_value2
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end
  end

  test "'day of week' and 'week of month' validation" do
    # should accept valid value
    valid_values1 = [0,1]
    valid_values2 = [*1..6]
    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @event.day_of_week = valid_value1
      @event.week_of_month = valid_value2
      @event_form = EventForm.new(@event)
      assert @event_form.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end

    valid_values1 = [*2..6]
    valid_values2 = [*1..5]
    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @event.day_of_week = valid_value1
      @event.week_of_month = valid_value2
      @event_form = EventForm.new(@event)
      assert @event_form.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end

    # reject invalid value
    invalid_values1 = [*0..6]
    invalid_values2 = [-1,0,7]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.week_of_month = invalid_value2
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end

    invalid_values1 = [*2..6]
    invalid_values2 = [6]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.week_of_month = invalid_value2
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end

    invalid_values1 = [-1,7,nil]
    invalid_values2 = [*1..6]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.week_of_month = invalid_value2
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end
  end

  test "'day of month' validation" do
    # should accept valid value
    valid_values = [*1..31,-1]
    valid_values.each do |valid_value|
      @event.day_of_month = valid_value
      @event_form = EventForm.new(@event)
      assert @event_form.valid?, "#{valid_value.inspect} should be valid"
    end

    # reject invalid value
    invalid_values = [-2,0,32]
    invalid_values.each do |invalid_value|
      @event.day_of_month = invalid_value
      @event_form = EventForm.new(@event)
      assert_not @event_form.valid?, "#{invalid_value.inspect} should be invalid"
    end
  end

  test "associated reminders should be destroyed" do
    @user.save
    event = @user.events.build(title: "test_1",
                                  description: "test_description1",
                                  start_date: "2021-06-16",
                                  end_date: nil,
                                  start_time: nil,
                                  end_time: nil,
                                  day_of_week: nil,
                                  with_order: nil,
                                  week_of_month: nil,
                                  day_of_month: nil,
                                  start_datetime: nil,
                                  end_datetime: nil)

    event.preprocess!.save!
    reminder = event.reminders.build(number: 10, unit: 1)
    reminder.preprocess!.save!
    assert_difference "Reminder.count", -1 do
      event.destroy
    end
  end

  ### reminder

  # test "event id should be present" do
  #   @reminder.event.start_date = "2021-06-16"
  #   @reminder.event_id = nil
  #   @event_form = EventForm.new(@reminder.event)
  #   assert_not @event_form.valid?
  # end

  test "number should be present" do
    @reminder.event.start_date = "2021-06-16"
    @reminder.number = nil
    @event_form = EventForm.new(@reminder.event)
    assert_not @event_form.valid?
  end

  test "unit should be present" do
    @reminder.event.start_date = "2021-06-16"
    @reminder.unit = nil
    @event_form = EventForm.new(@reminder.event)
    assert_not @event_form.valid?
  end

  test "number validation should accept valid value" do
    @reminder.event.start_date = "2021-06-16"
    valid_values = [*0..59]
    valid_values.each do |valid_value|
      @reminder.number = valid_value
      @event_form = EventForm.new(@reminder.event)
      assert @event_form.valid?, "#{valid_value.inspect} should be valid"
    end
  end

  test "number validation should reject invalid value" do
    @reminder.event.start_date = "2021-06-16"
    invalid_values = [-1,60]
    invalid_values.each do |invalid_value|
      @reminder.number = invalid_value
      @event_form = EventForm.new(@reminder.event)
      assert_not @event_form.valid?, "#{invalid_value.inspect} should be invalid"
    end
  end

  test "unit validation should accept valid value" do
    @reminder.event.start_date = "2021-06-16"
    valid_values = [*1..3]
    valid_values.each do |valid_value|
      @reminder.unit = valid_value
      @event_form = EventForm.new(@reminder.event)
      assert @event_form.valid?, "#{valid_value.inspect} should be valid"
    end
  end

  test "unit validation should reject invalid value" do
    @reminder.event.start_date = "2021-06-16"
    invalid_values = [-1,4]
    invalid_values.each do |invalid_value|
      @reminder.unit = invalid_value
      @event_form = EventForm.new(@reminder.event)
      assert_not @event_form.valid?, "#{invalid_value.inspect} should be invalid"
    end
  end
end
