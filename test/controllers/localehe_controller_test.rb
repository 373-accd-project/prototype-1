require 'test_helper'

class LocaleheControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "goes to home if not logged in" do
    get "/localehe"
    assert_redirected_to "/login"
  end
end
