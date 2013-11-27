require 'test_helper'

class ChatControllerTest < ActionController::TestCase
  test "should get connect" do
    get :connect
    assert_response :success
  end

  test "should get disconnect" do
    get :disconnect
    assert_response :success
  end

  test "should get message" do
    get :message
    assert_response :success
  end

end
