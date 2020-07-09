require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
  end

  test "miropost interface" do
    post_login_path(@user.email)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'

    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'

    content = "Lorem ipsum"
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, image: image } }
    end
    assert @user.microposts.first.image.attached?, 'Image should be attached to micropost'
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body, 'Created post content should be present on a page'

    assert_select 'a', text: 'Delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    get user_path(users(:bob))
    assert_select 'a', text: 'Delete', count: 0
  end

  test "micropost sidebar count" do
    post_login_path(@user.email)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body

    other_user = users(:user_1)
    post_login_path(other_user.email)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost!")
    get root_path
    assert_match "1 micropost", response.body
  end
end
