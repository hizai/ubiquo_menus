require File.dirname(__FILE__) + "/../../../../../../test/test_helper.rb"

class UbiquoMenus::Connectors::I18nTest < ActiveSupport::TestCase

  if Ubiquo::Plugin.registered[:ubiquo_i18n]
    def setup
      save_current_menus_connector
      UbiquoMenus::Connectors::I18n.load!
    end
    
    def teardown
      reload_old_menus_connector
      Locale.current = nil
    end
    
    test "Menu items are translatable" do
      assert MenuItem.is_translatable?
    end
    
    test "create menu items migration" do
      ActiveRecord::Migration.expects(:create_table).with(:menu_items, :translatable => true).once
      ActiveRecord::Migration.uhook_create_menu_items_table
    end
    
  end
  
  private
  
  def save_current_menus_connector
    @old_connector = UbiquoMenus::Connectors::Base.current_connector
  end

  def reload_old_menus_connector
    @old_connector.load!
  end
end
