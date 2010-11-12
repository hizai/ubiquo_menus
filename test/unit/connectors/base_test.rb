require File.dirname(__FILE__) + "/../../../../../../test/test_helper.rb"

module Connectors
  class BaseTest < ActiveSupport::TestCase
   
    test "find menu items returns all menu item" do
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {}, :session => {})
      Ubiquo::MenuItemsController.new.uhook_find_menu_items.each do |mi|
        assert mi.is_a?(MenuItem)
      end
    end
    
  end
end
