require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get help" do
    get help_path
    assert_response :success
    assert_template 'static_pages/help'

    assert_select "h1", "Help"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_template 'static_pages/about'

    assert_select "h1", "About"
  end
end