map.namespace :ubiquo do |ubiquo|
  ubiquo.resources :menu_items, :collection => { :update_positions => :put }
end
