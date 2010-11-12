module UbiquoMenus
  module Connectors
    class I18n < Standard

      def self.load!
        super
        ::MenuItem.send(:include, self::MenuItem)
      end

      # Validates the ubiquo_i18n-related dependencies
      def self.validate_requirements
        unless Ubiquo::Plugin.registered[:ubiquo_i18n]
          raise ConnectorRequirementError, "You need the ubiquo_i18n plugin to load #{self}"
        end
        [::MenuItem].each do |klass|
          if klass.table_exists?
            klass.reset_column_information
            columns = klass.columns.map(&:name).map(&:to_sym)
            unless [:locale, :content_id].all?{|field| columns.include? field}
              if Rails.env.test?
                ::ActiveRecord::Base.connection.change_table(klass.table_name, :translatable => true){}
                klass.reset_column_information
              else
                raise ConnectorRequirementError,
                  "The #{klass.table_name} table does not have the i18n fields. " +
                  "To use this connector, update the table enabling :translatable => true"
              end
            end
          end
        end
      end
      
      def self.unload!
        [::MenuItem].each do |klass|
          klass.instance_variable_set :@translatable, false
        end
        ::MenuItem.send :alias_method, :children, :children_without_shared_translations
        ::MenuItem.send :alias_method, :parent, :parent_without_shared_translations
        # Unfortunately there's no neat way to clear the helpers mess
        %w{MenuItems}.each do |controller_name|
          ::Ubiquo.send(:remove_const, "#{controller_name}Controller")
          load "ubiquo/#{controller_name.tableize}_controller.rb"
        end
      end

      module MenuItem
        def self.included(klass)
          klass.send :translatable, :caption
          klass.share_translations_for :children, :parent
        end
      end

      module UbiquoMenuItemsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          I18n.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          include Standard::UbiquoMenuItemsController::InstanceMethods

          # gets Menu items instances for the list and return it
          def uhook_find_menu_items
            ::MenuItem.locale(current_locale, :all).roots
          end

          # initialize a new instance of menu item
          def uhook_new_menu_item
            mi = ::MenuItem.translate(params[:from], current_locale)
            if mi.content_id.to_i == 0
              mi.parent_id = params[:parent_id] || 0
              mi.is_active = true
            end
            mi
          end

          def uhook_edit_menu_item(menu_item)
            unless menu_item.locale?(current_locale)
              redirect_to(ubiquo_menu_items_path)
              false
            end
          end

          #destroys a menu item instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu_item(menu_item)
            menu_item.destroy_content
          end

        end

        module Helper
          def uhook_extra_hidden_fields(form)
            form.hidden_field :content_id
          end
          def uhook_menu_item_links(menu_item)
            links = []

            if menu_item.in_locale?(current_locale)
              links << link_to(t("ubiquo.edit"), [:edit, :ubiquo, menu_item])
            else
              links << link_to(
                t("ubiquo.edit"),
                new_ubiquo_menu_item_path(
                  :from => menu_item.content_id
                  )
                )
            end
            links << link_to(t("ubiquo.remove"),
              ubiquo_menu_item_path(menu_item, :destroy_content => true),
              :confirm => t("ubiquo.menus.confirm_sitemap_removal"), :method => :delete
              )
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
          I18n.register_uhooks klass, ClassMethods
        end
        module ClassMethods
          include Standard::Migration::ClassMethods
          
          def uhook_create_menu_items_table
            create_table :menu_items, :translatable => true do |t|
              yield t
            end
          end
        end
      end
    end
    
  end
end
