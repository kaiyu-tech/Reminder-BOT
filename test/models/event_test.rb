require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    travel_to("2021-06-16 12:00:00 +0900")

    @user = users(:user_10)
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
  end

  test "should be valid" do
    @event.start_date = "2021-06-16"
    assert @event.valid?
  end

  test "user id should be present" do
    @event.user_id = nil
    assert_not @event.valid?
  end

  test "title should be present" do
    @event.start_date = "2021-06-16"
    @event.title = "     "
    assert_not @event.valid?
  end

  test "title should not be too long" do
    @event.start_date = "2021-06-16"
    @event.title = "x" * 31
    assert_not @event.valid?
  end

  test "description should not be too long" do
    @event.start_date = "2021-06-16"
    @event.description = "x" * 121
    assert_not @event.valid?
  end

  test "date validation" do
    # should accept valid value
    @event.start_date = "2021-06-16"
    @event.end_date = "2021-06-17"
    assert @event.valid?

    # reject invalid value
    @event.start_date = "2021-06-15"
    @event.end_date = nil
    assert_not @event.valid?

    @event.start_date = "2021-06-17"
    @event.end_date = "2021-06-16"
    assert_not @event.valid?

    @event.start_date = nil
    @event.end_date = "2021-06-16"
    assert_not @event.valid?

    @event.start_date = nil
    @event.day_of_week = nil
    @event.with_order = nil
    @event.week_of_month = nil
    @event.day_of_month = nil
    assert_not @event.valid?

    @event.start_date = "2021-06-16"
    @event.day_of_week = 1
    @event.day_of_month = nil
    assert_not @event.valid?

    @event.start_date = "2021-06-16"
    @event.day_of_week = nil
    @event.day_of_month = 1
    assert_not @event.valid?
  end

  test "time validation" do
    # should accept valid value
    @event.start_time = "0:00:00 +0900"
    @event.end_time = "1:00:00 +0900"
    assert @event.valid?

    # reject invalid value
    @event.start_time = "1:00:00 +0900"
    @event.end_time = "0:00:00 +0900"
    assert_not @event.valid?

    @event.start_time = nil
    @event.end_time = "0:00:00 +0900"
    assert_not @event.valid?

    @event.start_time = nil
    @event.day_of_week = nil
    @event.with_order = nil
    @event.week_of_month = nil
    @event.day_of_month = nil
    assert_not @event.valid?
  end

  test "'day of week' validation" do
    # should accept valid value
    valid_values = [*0..6]
    valid_values.each do |valid_value|
      @event.day_of_week = valid_value
      assert @event.valid?, "#{valid_value.inspect} should be valid"
    end

    # reject invalid value
    invalid_values = [-1,7,nil]
    invalid_values.each do |invalid_value|
      @event.day_of_week = invalid_value
      assert_not @event.valid?, "#{invalid_value.inspect} should be invalid"
    end

    @event.day_of_week = 1
    @event.day_of_month = 25
    assert_not @event.valid?
  end

  test "'day of week' and 'with order' validation" do
    # should accept valid value
    valid_values1 = [*0..6]
    valid_values2 = [*1..5]
    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @event.day_of_week = valid_value1
      @event.with_order = valid_value2
      assert @event.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end

    # reject invalid value
    invalid_values1 = [*0..6]
    invalid_values2 = [-1,0,6]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.with_order = invalid_value2
      assert_not @event.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end

    invalid_values1 = [-1,7,nil]
    invalid_values2 = [*1..5]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.with_order = invalid_value2
      assert_not @event.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end
  end

  test "'day of week' and 'week of month' validation" do
    # should accept valid value
    valid_values1 = [0,1]
    valid_values2 = [*1..6]
    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @event.day_of_week = valid_value1
      @event.week_of_month = valid_value2
      assert @event.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end

    valid_values1 = [*2..6]
    valid_values2 = [*1..5]
    valid_values1.product(valid_values2) do |valid_value1, valid_value2|
      @event.day_of_week = valid_value1
      @event.week_of_month = valid_value2
      assert @event.valid?, "#{valid_value1.inspect} and #{valid_value2.inspect} should be valid"
    end

    # reject invalid value
    invalid_values1 = [*0..6]
    invalid_values2 = [-1,0,7]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.week_of_month = invalid_value2
      assert_not @event.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end

    invalid_values1 = [*2..6]
    invalid_values2 = [6]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.week_of_month = invalid_value2
      assert_not @event.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end

    invalid_values1 = [-1,7,nil]
    invalid_values2 = [*1..6]
    invalid_values1.product(invalid_values2) do |invalid_value1, invalid_value2|
      @event.day_of_week = invalid_value1
      @event.week_of_month = invalid_value2
      assert_not @event.valid?, "#{invalid_value1.inspect} and #{invalid_value2.inspect} should be invalid"
    end
  end

  test "'day of month' validation" do
    # should accept valid value
    valid_values = [*1..31,-1]
    valid_values.each do |valid_value|
      @event.day_of_month = valid_value
      assert @event.valid?, "#{valid_value.inspect} should be valid"
    end

    # reject invalid value
    invalid_values = [-2,0,32]
    invalid_values.each do |invalid_value|
      @event.day_of_month = invalid_value
      assert_not @event.valid?, "#{invalid_value.inspect} should be invalid"
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

  ###

  test "datetime from date" do
    @event.start_date = "2021-06-16"
    @event.end_date = nil
    assert_equal @event.send(:date_type), :oneday
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16"

    @event.start_date = "2021-06-16"
    @event.end_date = "2021-06-25"
    assert_equal @event.send(:date_type), :range
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16".in_time_zone
    assert_equal @event.end_datetime, "2021-06-25 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16\nFri, 2021/06/25"
  end

  test "datetime from date and time" do
    @event.start_date = "2021-06-16"
    @event.end_date = nil
    @event.start_time = "09:00:00 +0900"
    @event.end_time = nil
    assert_equal @event.send(:date_type), :oneday
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16 09:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 09:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16 09:00 [Ended]"

    @event.start_date = "2021-06-16"
    @event.end_date = nil
    @event.start_time = "09:00:00 +0900"
    @event.end_time = "12:00:00 +0900"
    assert_equal @event.send(:date_type), :oneday
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16 09:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16 09:00 - 12:00"

    @event.start_date = "2021-06-16"
    @event.end_date = "2021-06-25"
    @event.start_time = "09:00:00 +0900"
    @event.end_time = "12:00:00 +0900"
    assert_equal @event.send(:date_type), :range
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16 09:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-25 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16 09:00\nFri, 2021/06/25 12:00"
  end

  test "datetime from time" do
    @event.start_time = "12:00:00 +0900"
    @event.end_time = nil
    assert_equal @event.send(:date_type), :daily
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-17 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-17 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Thu, 2021/06/17 12:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    assert_equal @event.send(:date_type), :daily
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-17 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-17 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Thu, 2021/06/17 12:00 - 15:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = nil
    assert_equal @event.send(:date_type), :daily
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-17 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-17 00:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Thu, 2021/06/17 00:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    assert_equal @event.send(:date_type), :daily
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-17 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-17 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Thu, 2021/06/17 00:00 - 15:00"
  end

  test "datetime from day of week and time" do
    @event.start_time = "09:00:00 +0900"
    @event.end_time = nil
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :weekly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-23 09:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-23 09:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/23 09:00"

    @event.start_time = "09:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :weekly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-23 09:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-23 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/23 09:00 - 15:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = nil
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :weekly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-23 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-23 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/23 12:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :weekly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-23 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-06-23 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/23 12:00 - 15:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = nil
    @event.day_of_week = 3 # :wednesday
    @event.with_order = 3
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :day_of_week1
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-21 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-21 00:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/21 00:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_week = 3 # :wednesday
    @event.with_order = 3
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :day_of_week1
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-21 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-21 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/21 00:00 - 15:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = nil
    @event.day_of_week = 3 # :wednesday
    @event.with_order = 3
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :day_of_week1
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-21 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-21 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/21 12:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_week = 3 # :wednesday
    @event.with_order = 3
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :day_of_week1
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-21 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-21 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/21 12:00 - 15:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = nil
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = 3
    assert_equal @event.send(:date_type), :day_of_week2
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-14 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-14 00:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/14 00:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = 3
    assert_equal @event.send(:date_type), :day_of_week2
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-14 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-14 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/14 00:00 - 15:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = nil
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = 3
    assert_equal @event.send(:date_type), :day_of_week2
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-14 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-14 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/14 12:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = 3
    assert_equal @event.send(:date_type), :day_of_week2
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-14 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-14 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/07/14 12:00 - 15:00"
  end

  test "datetime from day of month and time" do
    @event.start_time = "00:00:00 +0900"
    @event.end_time = nil
    @event.day_of_month = 16
    assert_equal @event.send(:date_type), :monthly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-16 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-16 00:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Fri, 2021/07/16 00:00"

    @event.start_time = "00:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_month = 16
    assert_equal @event.send(:date_type), :monthly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-16 00:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-16 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Fri, 2021/07/16 00:00 - 15:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = nil
    @event.day_of_month = 16
    assert_equal @event.send(:date_type), :monthly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-16 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-16 12:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Fri, 2021/07/16 12:00"

    @event.start_time = "12:00:00 +0900"
    @event.end_time = "15:00:00 +0900"
    @event.day_of_month = 16
    assert_equal @event.send(:date_type), :monthly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-16 12:00:00 +0900".in_time_zone
    assert_equal @event.end_datetime, "2021-07-16 15:00:00 +0900".in_time_zone
    assert_equal @event.datetime_to_string, "Fri, 2021/07/16 12:00 - 15:00"
  end

  test "datetime from day of week" do
    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :weekly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16"

    @event.day_of_week = 0 # :sunday
    @event.with_order = nil
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :weekly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-20".in_time_zone
    assert_equal @event.end_datetime, "2021-06-20 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Sun, 2021/06/20"

    @event.day_of_week = 3 # :wednesday
    @event.with_order = 3
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :day_of_week1
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16"

    @event.day_of_week = 0 # :sunday
    @event.with_order = 5
    @event.week_of_month = nil
    assert_equal @event.send(:date_type), :day_of_week1
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-08-29".in_time_zone
    assert_equal @event.end_datetime, "2021-08-29 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Sun, 2021/08/29"

    @event.day_of_week = 3 # :wednesday
    @event.with_order = nil
    @event.week_of_month = 3
    assert_equal @event.send(:date_type), :day_of_week2
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16"

    @event.day_of_week = 0 # :sunday
    @event.with_order = nil
    @event.week_of_month = 6
    assert_equal @event.send(:date_type), :day_of_week2
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-10-31".in_time_zone
    assert_equal @event.end_datetime, "2021-10-31 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Sun, 2021/10/31"
  end

  test "datetime from day of month" do
    @event.day_of_month = 16
    assert_equal @event.send(:date_type), :monthly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-06-16".in_time_zone
    assert_equal @event.end_datetime, "2021-06-16 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Wed, 2021/06/16"

    @event.day_of_month = 31
    assert_equal @event.send(:date_type), :monthly
    @event.preprocess!
    assert_equal @event.start_datetime, "2021-07-31".in_time_zone
    assert_equal @event.end_datetime, "2021-07-31 23:59:59 +09:00".in_time_zone
    assert_equal @event.datetime_to_string, "Sat, 2021/07/31"
  end

  test "search for events by datetime" do
    # today
    text = Event.search(@user.line_id_digest, Time.zone.now, Time.zone.today.end_of_day)
    assert_equal text, "【title1-1】\ntoday\nWed, 2021/06/16"
    # tomorrow
    text = Event.search(@user.line_id_digest, Time.zone.tomorrow.midnight, Time.zone.tomorrow.end_of_day)
    assert_equal text, "【title1-2】\ntomorrow\nThu, 2021/06/17"
    # today and tomorrow
    text = Event.search(@user.line_id_digest, Time.zone.now, Time.zone.tomorrow.end_of_day)
    assert_equal text, "【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17"
    # this week
    text = Event.search(@user.line_id_digest, Time.zone.now, Time.zone.now.end_of_week(:sunday))
    assert_equal text, "【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17"
    # next week
    text = Event.search(@user.line_id_digest, Time.zone.now.beginning_of_week(:sunday) + 1.week, Time.zone.now.end_of_week(:sunday) + 1.week)
    assert_equal text, "【title2】\nnext week\nWed, 2021/06/23"
    # this month
    text = Event.search(@user.line_id_digest, Time.zone.now, Time.zone.now.end_of_month)
    assert_equal text, "【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17\n\n" \
                          "【title2】\nnext week\nWed, 2021/06/23"
    # next month
    text = Event.search(@user.line_id_digest, Time.zone.now.next_month.beginning_of_month, Time.zone.now.next_month.end_of_month)
    assert_equal text, "【title3】\nnext month\nFri, 2021/07/16"
  end

  test "search for events by word" do
    text = Event.word(@user.line_id_digest, "title1")
    assert_equal text, "【title1-1】\ntoday\nWed, 2021/06/16\n\n" \
                          "【title1-2】\ntomorrow\nThu, 2021/06/17"
  end
end
