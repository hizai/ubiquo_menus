require File.dirname(__FILE__) + "/../../../../../../test/test_helper.rb"

module Connectors
  class StandardTest < ActiveSupport::TestCase
    def setup
      UbiquoMenus::Connectors::Standard.load!
    end

    test "menu_items_controller find menu items" do
      assert_equal_set MenuItem.all.select{|mi|mi.is_root?}, Ubiquo::MenuItemsController.new.uhook_find_menu_items
    end

    test "menu_items_controller new menu item without parent" do
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {})
      mi = Ubiquo::MenuItemsController.new.uhook_new_menu_item
      assert_equal 0, mi.parent_id
      assert mi.new_record?
    end

    test "menu_items_controller new menu item with parent" do
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {:parent_id => 2})
      mi = Ubiquo::MenuItemsController.new.uhook_new_menu_item
      assert_equal 2, mi.parent_id
      assert mi.new_record?
    end

    test "menu_items_controller create menu item" do
      options = {
        :caption => "Caption",
        :url => "http://www.gnuine.com",
        :description => "Gnuine webpage",
        :is_linkable => true,
        :parent_id => 0,
        :position => 0,
      }
      Ubiquo::MenuItemsController.any_instance.stubs(:params => {:menu_item => options})
      assert_difference "MenuItem.count" do
        mi = Ubiquo::MenuItemsController.new.uhook_create_menu_item
      end
    end

    test "menu_items_controller destroy menu item" do
      mi = menu_items(:one)
      assert_difference "MenuItem.count", -1*(1+mi.children.size) do
        Ubiquo::MenuItemsController.new.uhook_destroy_menu_item(mi)
      end
    end

    test "create menu items migration" do
      ActiveRecord::Migration.expects(:create_table).with(:menu_items).once
      ActiveRecord::Migration.uhook_create_menu_items_table
    end

  end
end
