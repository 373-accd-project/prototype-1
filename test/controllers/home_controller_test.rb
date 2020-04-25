require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "should load the home page even when not logged in" do
    get home_path
    assert_response :success
  end

  test "should get the home page when logged in" do
    @user = User.create(username: "admin", password: "secret", password_confirmation: "secret", admin: true, api_key: "blank")
    post login_url(username: "admin", password: "secret")
    assert session[:user_id] == @user.id
    assert_redirected_to(controller: :home)
    get '/qcew'
    assert_response :success
  end
end