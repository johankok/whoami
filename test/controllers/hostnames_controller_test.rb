require 'test_helper'

class HostnamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hostname = Socket.gethostname
  end

  test 'should get index as html' do
    get hostname_url
    assert_response :success
    assert_match(@hostname, response.body)
  end

  test 'should get index as json' do
    get hostname_url, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal(@hostname, json['hostname'])
  end
end
