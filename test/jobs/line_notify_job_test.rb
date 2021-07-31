require 'test_helper'

class LineNotifyJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  def setup
    travel_to("2021-05-16 12:00:00 +0900")

    @event_20 = events(:event_20) # :range
    @event_21 = events(:event_21) # :oneday
    @event_22 = events(:event_22) # :daily
    @event_23 = events(:event_23) # :daily
    @event_24 = events(:event_24) # :weekly
    @event_25 = events(:event_25) # :day_of_week1
    @event_26 = events(:event_26) # :day_of_week2
    @event_27 = events(:event_27) # :monthly

    @event_28 = events(:event_28) # 30 minutes later
    @event_29 = events(:event_29) # 1 hour later
    @event_30 = events(:event_30) # 1 day later

    @event_31 = events(:event_31) # no token is set
  end

  test "successfully run line notify" do
    LineNotifyJob.perform_now

    @event_20.reload
    @event_21.reload
    @event_22.reload
    @event_23.reload
    @event_24.reload
    @event_25.reload
    @event_26.reload
    @event_27.reload

    now = "2021-05-16 12:00:00 +0900".in_time_zone

    datetime = "2021-05-16 12:00:00 +0900".in_time_zone
    assert_equal @event_20.start_datetime, datetime
    @event_20.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_20.user.reminded_at, now

    datetime = "2021-05-16 12:00:00 +0900".in_time_zone
    assert_equal @event_21.start_datetime, datetime
    @event_21.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_21.user.reminded_at, now

    datetime = "2021-05-17 12:00:00 +0900".in_time_zone
    assert_equal @event_22.start_datetime, datetime
    @event_22.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_22.user.reminded_at, now

    datetime = "2021-05-16 12:00:00 +0900".in_time_zone
    assert_equal @event_23.start_datetime, datetime
    @event_23.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_23.user.reminded_at, now

    datetime = "2021-05-23 12:00:00 +0900".in_time_zone
    assert_equal @event_24.start_datetime, datetime
    @event_24.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_24.user.reminded_at, now

    datetime = "2021-06-20 12:00:00 +0900".in_time_zone
    assert_equal @event_25.start_datetime, datetime
    @event_25.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_25.user.reminded_at, now

    datetime = "2021-06-13 12:00:00 +0900".in_time_zone
    assert_equal @event_26.start_datetime, datetime
    @event_26.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_26.user.reminded_at, now

    datetime = "2021-06-16 12:00:00 +0900".in_time_zone
    assert_equal @event_27.start_datetime, datetime
    @event_27.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_27.user.reminded_at, now

    @event_28.reload
    @event_29.reload
    @event_30.reload

    datetime = "2021-05-16 12:30:00 +0900".in_time_zone
    assert_equal @event_28.start_datetime, datetime
    @event_28.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_28.user.reminded_at, now

    datetime = "2021-05-16 13:00:00 +0900".in_time_zone
    assert_equal @event_29.start_datetime, datetime
    @event_29.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_29.user.reminded_at, now

    datetime = "2021-05-17 12:00:00 +0900".in_time_zone
    assert_equal @event_30.start_datetime, datetime
    @event_30.reminders.each do |reminder|
      assert_equal reminder.remind_at, datetime - reminder.remind_time
    end
    assert_equal @event_30.user.reminded_at, now

    ###

    @event_31.reload
    assert_equal @event_31.user.reminded_at, "2021-05-16 11:59:00".in_time_zone
    @event_31.user.notify_token_encrypt = User.encrypt(ENV['LINE_NOTIFY_TOKEN'])
    @event_31.user.save!

    LineNotifyJob.perform_now

    @event_31.reload
    assert_equal @event_31.user.reminded_at, now
  end
end
