require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include SessionsHelper

  def setup
    travel_to("2021-06-16 12:00:00 +0900")

    @user = User.new(line_id_digest: User.digest("line_id_dummy"),
                      line_name: "line_name",
                      admin: false,
                      activate: false,
                      expires_in: nil,
                      notify_token_encrypt: nil,
                      reminded_at: nil)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "'line id digest' should be present" do
    @user.line_id_digest = nil
    assert_not @user.valid?
  end

  test "'line id digest' should not be too long" do
    @user.line_id_digest = "x" * 256
    assert_not @user.valid?
  end

  test "'line id digest' should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "'line name' should be present" do
    @user.line_name = nil
    assert_not @user.valid?
  end

  test "'line name' should not be too long" do
    @user.line_name = "x" * 256
    assert_not @user.valid?
  end

  test "admin should be present" do
    @user.admin = nil
    assert_not @user.valid?
  end

  test "activate should be present" do
    @user.activate = nil
    assert_not @user.valid?
  end

  test "'notify token encrypt' should not be too long" do
    @user.notify_token_encrypt = "x" * 256
    assert_not @user.valid?
  end

  test "compare? should return true" do
    assert @user.compare?("line_id_dummy")
  end

  test "compare? should return false" do
    assert_not @user.compare?("")
  end

  test "associated events and reminders should be destroyed" do
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
    reminder.preprocess!
    event.save!
    assert_difference ['Event.count', 'Reminder.count'], -1 do
      @user.destroy
    end
  end
end
