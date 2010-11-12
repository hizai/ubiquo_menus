module UbiquoMenus
  module Extensions
    module Helper
      def sitemap_tab(tabnav)
        tabnav.add_tab do |tab|
          tab.text =  I18n.t("ubiquo.menus.sitemap")
          tab.title =  I18n.t("ubiquo.menus.sitemap_title")
          tab.highlights_on({:controller => "ubiquo/menu_items"})
          tab.link = ubiquo_menu_items_path
        end if ubiquo_config_call :sitemap_permit, {:context => :ubiquo_menus}
      end
    end
  end
end
