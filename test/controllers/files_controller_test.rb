require 'test_helper'

class FilesControllerTest < ActionController::TestCase
  setup do
    @file = fyles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:files) # stupidly and confusingly called @files (not @fyles) in FilesController#index
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create file" do
    assert_difference('Fyle.count') do
      post :create, fyle: { URL: @file.URL, strip_end: @file.strip_end, strip_start: @file.strip_start, what: @file.what }
    end

    assert_redirected_to fyle_path(assigns(:file))
  end

  test "should show file" do
    get :show, id: @file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @file
    assert_response :success
  end

  test "should update file" do
    patch :update, id: @file, fyle: { URL: @file.URL, strip_end: @file.strip_end, strip_start: @file.strip_start, what: @file.what }
    assert_redirected_to fyle_path(assigns(:file))
  end

  test "should destroy file" do
    assert_difference('Fyle.count', -1) do
      delete :destroy, id: @file
    end

    assert_redirected_to fyles_path
  end
end
