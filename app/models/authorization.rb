class Authorization
  extend Lockdown::Access

  #----------------------------------------------------------------------------
  # Public
  #----------------------------------------------------------------------------

# Access to methods (:new, :create, :confirm) on the users controller
#  permission 'create-user' do
#    controller 'users' do
#      only 'new', 'create', 'confirm'
#    end
#  end

  # Access to all methods on the user_sessions controller
  permission 'session' do
    controller 'backend/session' do
      except 'destroy'
    end
  end


 permission 'decision_for_client' do
    controller 'backend/orders' do
      only  'new_decision_design','accept_design'
    end
  end


  permission 'public_access_frontend' do
    controller 'frontend/aboutus'
    controller 'frontend/budgets'
    controller 'frontend/designs'
    controller 'frontend/home'
    controller 'frontend/products'
    controller 'frontend/users' do
      only 'new','create'
    end
    controller 'frontend/session'
    controller 'frontend/static_contents'
  end

  permission 'protected_access_frontend' do
    controller 'frontend/contacts'
    controller 'frontend/users'
  end


  # Make the above permissions available publicly
  public_access \
    'public_access_frontend','session','decision_for_client'

  #----------------------------------------------------------------------------
  # Protected
  #----------------------------------------------------------------------------


  permission 'home_backend' do
    controller 'backend/session' do
      only 'destroy'
    end
    controller 'backend/home'
  end


  permission 'contacts_backend' do
    controller 'backend/contacts'
  end
  permission 'contacts_show_backend' do
    controller 'backend/contacts' do
      only 'index','show'
    end
  end


  permission 'orders_backend' do
    controller 'backend/orders'
  end
  permission 'orders_backend_by_user' do
    controller 'backend/orders' do
      except 'reassign_tracker','cancel'
    end
  end
  permission 'orders_show_backend' do
    controller 'backend/orders' do
      only 'index','show','new_comment','add_comment','show_design','show_tracker','search'
    end
  end

  permission 'budgets_backend' do
    controller 'backend/budgets'
    controller 'backend/contacts' do
      only 'autocomplete_by_client_name', 'autocomplete_by_client_identification'
    end
    controller 'backend/products' do
      only 'autocomplete', 'select_prices'
    end
  end
  permission 'budgets_without_generate_orden_backend' do
    controller 'backend/budgets' do
      except 'order_generate'
    end
    controller 'backend/contacts' do
      only 'autocomplete_by_client_name', 'autocomplete_by_client_identification'
    end
    controller 'backend/products' do
      only 'autocomplete', 'select_prices'
    end
  end


  permission 'raw_materials_backend' do
    controller 'backend/raw_materials'
  end
  permission 'raw_materials_whitout_alter_inventory_backend' do
    controller 'backend/raw_materials' do
      except 'remove_inventory'
    end
  end


  permission 'multimedia_files_backend' do
    controller 'backend/multimedia_files'
  end


  permission 'invoices_backend' do
    controller 'backend/invoices'
    controller 'backend/contacts' do
      only 'autocomplete_by_client_name', 'autocomplete_by_client_identification'
    end
    controller 'backend/products' do
      only 'autocomplete', 'select_prices','autocomplete_by_code'
    end
  end
  permission 'invoices_whitout_alter_items_backend' do
    controller 'backend/invoices'
  end

	permission 'purchase_orders_backend' do
		controller 'backend/purchase_orders'
	end

	permission 'goods_receipts_backend' do
		controller 'backend/goods_receipts'
	end

	permission 'goods_movements_backend' do
		controller 'backend/goods_movements'
	end

	permission 'incoming_invoices_backend' do
		controller 'backend/incoming_invoices'
	end

  permission 'credit_notes_backend' do
    controller 'backend/credit_notes'
  end
  permission 'credit_notes_whitout_alter_items_backend' do
    controller 'backend/credit_notes' do
      except 'remove_product'
    end
  end

  
  permission 'reports_backend' do
    controller 'backend/reports'
  end


  permission 'shortcuts_backend' do
    controller 'backend/shortcuts'
  end


  permission 'cpanel_backend' do
    controller 'backend/cpanel/digital_cards'
    controller 'backend/cpanel/state_matrices'
    controller 'backend/cpanel/packing_materials'
		controller 'backend/cpanel/additional_component_types'
		controller 'backend/cpanel/accessory_component_types'
		controller 'backend/cpanel/price_list_component_accesories'
    controller 'backend/cpanel/raw_material_price_definition_set_color_by_components'
    controller 'backend/cpanel/raw_material_price_definition_set_black_by_components'
		controller 'backend/cpanel/home'
		controller 'backend/cpanel/users'
		controller 'backend/goods_movements'
  end

  permission 'human_resource_backend' do
    controller 'backend/human_resource/employees'
		controller 'backend/human_resource/last_payrolls'

  end

	permission 'cash_bank_backend' do
    controller 'backend/cashbank/bank_movements'
		controller 'backend/cashbank/banks'
		controller 'backend/cashbank/bank_accounts'
		controller 'backend/cashbank/checkbooks'
		controller 'backend/cashbank/check_offereds'
		controller 'backend/cashbank/cashes'
		controller 'backend/cashbank/bank_reconciliations'
  end

	permission 'accountancy_backend' do
    controller 'backend/accountancy/accountant_accounts'
		controller 'backend/accountancy/accounting_concepts'
  end


	permission 'web_designs_backend' do
    controller 'backend/web_design/custom_designs'
		controller 'backend/web_design/home_page_slides'
    controller 'backend/web_design/base'
  end



  # Make the above permissions available to only authenticated users
  protected_access \
    'protected_access_frontend'
    #    'home_backend'

  # Access to all methods on the subscriptions controller
  #  permission 'admin-subscriptions' do
  #    controller 'subscriptions'
  #  end

  # Users with the 'admin-products' user group will be able to do it all.
  #  user_group 'reportes', 'manage-reports'
  #  user_group 'informacion', 'manage-monitor'
#  user_group 'supervisor', 'home_backend','orders_backend','budgets_backend','invoices_backend'
#  user_group 'designer', 'home_backend','orders_backend'
#  user_group 'printer', 'home_backend','budgets_backend','invoices_backend','orders_backend'
#  user_group 'biller', 'home_backend','budgets_backend','invoices_backend'
#  user_group 'configurator', 'home_backend','budgets_backend','invoices_backend','cpanel_backend','raw_materials_backend','protected_access_frontend'
#  user_group 'reporting', 'home_backend','reports_backend'


  user_gruop 'analista_administrativo', 'home_backend', 'contacts_backend', 'raw_materials_whitout_alter_inventory_backend','budgets_backend','invoices_backend','credit_notes_whitout_alter_items_backend','orders_show_backend','reports_backend','shortcuts_backend'
  user_gruop 'asistente_administrativo', 'home_backend', 'contacts_backend', 'raw_materials_whitout_alter_inventory_backend','budgets_without_generate_orden_backend','orders_show_backend','shortcuts_backend'
  user_group 'asistente_comercial','home_backend','contacts_backend','budgets_backend','invoices_whitout_alter_items_backend','credit_notes_whitout_alter_items_backend','orders_backend_by_user','shortcuts_backend'
  user_group 'supervisor_comercial','home_backend','contacts_backend','budgets_backend','invoices_whitout_alter_items_backend','credit_notes_whitout_alter_items_backend','orders_backend','shortcuts_backend','web_designs_backend'
  user_group 'disenador','home_backend','contacts_show_backend','orders_backend_by_user'
  user_group 'tecnico_grafico','home_backend','orders_backend_by_user','contacts_show_backend'
end
