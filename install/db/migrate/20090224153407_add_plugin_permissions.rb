class AddPluginPermissions < ActiveRecord::Migration
  def self.up
    Permission.create :key => "sitemap_management", :name => "Sitemap management"
  end

  def self.down
    Permission.destroy_all(:key => %w[sitemap_management])
  end
end
