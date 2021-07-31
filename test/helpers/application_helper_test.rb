require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test "full title helper" do
    assert_equal full_title, "Reminder Bot"
    assert_equal full_title("Connect"), "Connect | Reminder Bot"
    assert_equal full_title("Events"), "Events | Reminder Bot"
    assert_equal full_title("Users"), "Users | Reminder Bot"
    assert_equal full_title("Help"), "Help | Reminder Bot"
    assert_equal full_title("About"), "About | Reminder Bot"
  end
end