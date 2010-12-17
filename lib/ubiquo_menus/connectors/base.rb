module UbiquoMenus
  module Connectors
    class Base < Ubiquo::Connectors::Base

      # Load all the modules required for an UbiquoMenus connector
      def self.load!
        [::MenuItem].each(&:reset_column_information)
        if current = UbiquoMenus::Connectors::Base.current_connector
          current.unload!
        end
        validate_requirements
        ::Ubiquo::MenuItemsController.send(:include, self::UbiquoMenuItemsController)
        ::ActiveRecord::Migration.send(:include, self::Migration)
        UbiquoMenus::Connectors::Base.set_current_connector self
      end
    end
  end
end
