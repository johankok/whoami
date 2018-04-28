require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_redirected_to hostname_url
  end
end
