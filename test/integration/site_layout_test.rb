require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test 'layout links' do
    get root_path
    assert_template 'static_pages/home'

    assert_select "a[href=?]", root_path, text: "sample app"
    assert_select "a[href=?]", root_path, text: "Home"
    assert_select "a[href=?]", help_path, text: "Help"
    assert_select "a[href=?]", about_path, text: "About"
    assert_select "a[href=?]", contact_path, text: "Contact"

    get contact_path
    assert_select "title", full_title("Contact")

    get help_path
    assert_select "title", full_title("Help")

    get about_path
    assert_select "title", full_title("About")
  end

end
