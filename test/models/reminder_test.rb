require 'test_helper'

class ReminderTest < ActiveSupport::TestCase
  def setup
    travel_to("2021-06-16 12:00:00 +0900")

    @event = events(:event_3)
    @reminder = @event.reminders.build(number: 10, unit: 1, remind_at: nil)
  end

  test "should be valid" do
    assert @reminder.valid?
  end

  test "event id should be present" do
    @reminder.event_id = nil
    assert_not @reminder.valid?
  end

  test "number should be present" do
    @reminder.number = nil
    assert_not @reminder.valid?
  end

  test "unit should be present" do
    @reminder.unit = nil
    assert_not @reminder.valid?
  end

  test "number and unit validation should accept valid value" do
    valid_values1 = [*0..59]
    valid_values2 = [*1..3]
    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @reminder.number = valid_value1
      @reminder.unit = valid_value2
      assert @reminder.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end
  end

  test "number validation should reject invalid value" do
    invalid_values = [-1,60]
    valid_values = [*1..3]
    invalid_values.product(valid_values) do |invalid_value, valid_value|
      @reminder.number = invalid_value
      @reminder.unit = valid_value
      assert_not @reminder.valid?, "#{invalid_value.inspect} and #{valid_value.inspect} should be invalid"
    end
  end

  test "unit validation should reject invalid value" do
    valid_values = [*0..59]
    invalid_values = [-1,0,4]
    valid_values.product(invalid_values) do |valid_value, invalid_value|
      @reminder.number = valid_value
      @reminder.unit = invalid_value
      assert_not @reminder.valid?, "#{valid_value.inspect} and #{invalid_value.inspect} should be valid"
    end
  end

  test "'remind at' from time" do
    reminder = @event.reminders.build

    reminder.number = 10
    reminder.unit = 1
    assert_equal reminder.remind_time, 10.minutes
    reminder.preprocess!
    assert_equal reminder.remind_at, "2021-06-16 11:50:00".in_time_zone

    reminder.number = 1
    reminder.unit = 2
    assert_equal reminder.remind_time, 1.hour
    reminder.preprocess!
    assert_equal reminder.remind_at, "2021-06-16 11:00:00".in_time_zone

    reminder.number = 1
    reminder.unit = 3
    assert_equal reminder.remind_time, 1.day
    reminder.preprocess!
    assert_equal reminder.remind_at, "2021-06-15 12:00:00".in_time_zone
  end
end
