module UbiquoMenus
  module Connectors
    class Standard < Base
            module UbiquoMenuItemsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods

          # gets Menu items instances for the list and return it
          def uhook_find_menu_items
            ::MenuItem.roots
          end

          # initialize a new instance of menu item
          def uhook_new_menu_item
            ::MenuItem.new(:parent_id => (params[:parent_id] || 0), :is_active => true)
          end
          def uhook_edit_menu_item(menu_item)
            true
          end


          # creates a new instance of menu item
          def uhook_create_menu_item
            mi = ::MenuItem.new(params[:menu_item])
            mi.save
            mi
          end

          #updates a menu item instance. returns a boolean that means if update was done.
          def uhook_update_menu_item(menu_item)
            menu_item.update_attributes(params[:menu_item])
          end

          #destroys a menu item instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu_item(menu_item)
            menu_item.destroy
          end

        end
        module Helper
          def uhook_extra_hidden_fields(form)
          end
          def uhook_menu_item_links(menu_item)
            links = []

            links << link_to(t('ubiquo.edit'), edit_ubiquo_menu_item_path(menu_item))
            links << link_to(t('ubiquo.remove'), [:ubiquo, menu_item],
              :confirm => t('ubiquo.menus.confirm_sitemap_removal'),
              :method => :delete)
            if menu_item.can_have_children?
              links << link_to(t('ubiquo.menus.new_subsection'), new_ubiquo_menu_item_path(:parent_id => menu_item))
            end

            links.join(" | ")
          end
        end
      end

      module Migration

        def self.included(klass)
          klass.send(:extend, ClassMethods)
          Standard.register_uhooks klass, ClassMethods
        end

        module ClassMethods
          def uhook_create_menu_items_table
            create_table :menu_items do |t|
              yield t
            end
          end
        end
      end      

    end
  end
end
