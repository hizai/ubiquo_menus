require 'ubiquo_menus'

config.after_initialize do
  UbiquoMenus::Connectors.load!
end

Ubiquo::Plugin.register(:ubiquo_menus, directory, config) do |config|
  config.add :sitemap_access_control, lambda{
    access_control :DEFAULT => "sitemap_management"
  }
  config.add :sitemap_permit, lambda{
    permit?("sitemap_management")
  }

  # Connectors available in the application.
  # These connectors will be tested against the Base uhooks api
  config.add :available_connectors, [:i18n, :standard]

  # Currently enabled connector
  config.add :connector, :standard
end
