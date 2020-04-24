require 'test_helper'

class NationaleheControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "goes to home if not logged in" do
    get "/nationalehe"
    assert_redirected_to "/login"
  end
end
