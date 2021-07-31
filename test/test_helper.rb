ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all
  include ApplicationHelper
  include SessionsHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper
end

class ActionDispatch::IntegrationTest

  def connect_as(id_token, all = nil)
    if all
      post sessions_path, params: { id_token: id_token, all: true }
    else
      post sessions_path, params: { id_token: id_token }
    end
  end
end