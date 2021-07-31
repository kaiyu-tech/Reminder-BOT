require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get help_path
    assert_select "title", full_title("Help")

    get about_path
    assert_select "title", full_title("About")
  end
end