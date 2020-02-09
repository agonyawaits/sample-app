require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test "full title helper" do
    base_title = "Ruby on Rails Tutorial Sample App"
    assert_equal full_title, base_title

    pages = ["Help", "Contact", "About"]
    pages.each do |page|
      assert_equal full_title(page), page + " | " + base_title
    end
  end

end
