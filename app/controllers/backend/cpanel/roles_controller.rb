class Backend::Cpanel::RolesController < Backend::Cpanel::BaseController

  def index
    @roles = Security::Role.all
    @title = "Perfiles"
  end

  def new
    @role = Security::Role.new
    @permissions = @role.security_permissions
    @title = "Perfiles / Nuevo"
  end

  def create
    @role = Security::Role.new(params[:security_role])
    @success = @role.valid?
    if @success
      @role.save
    end
  end

  def show
    @title = "Perfiles / Detalle"
    @role = Security::Role.find(params[:id])
    @permissions = @role.security_permissions
  end

  def edit
    @title = "Perfiles / Detalle"
    @role = Security::Role.find(params[:id])
    @permissions = @role.security_permissions
  end

  def update
    @role = Security::Role.find(params[:id])
  end

  def new_permission
    @role = Security::Role.find(params[:role_id])
    @permission = Security::Permission.new
    @permission.security_role = @role
  end

  def add_permission
     action_methods_name = []
     @role = Security::Role.find(params[:role_id])
     @permission = Security::Permission.new(params[:security_permission])
     @permission.security_role = @role
     params[:action_methods_name].each do |action_method_name_key,action_method_name_value|
        action_methods_name << action_method_name_key if action_method_name_value.eql?("true")
     end
     @permission.action_name = action_methods_name.join(", ")
     @success = @permission.valid?
     if @success
       @permission.save
     end
  end

  def remove_permission
    @role = Security::Role.find(params[:role_id])
    @permission = Security::Permission.find(params[:permission_id])
    @success = @permission.delete
  end

	def set_submodule
		@module = ConfigPanel::Module.find(params[:security_permission][:config_panel_module_id])
	end
 
  def search_actions_controller
    @submodule = ConfigPanel::Submodule.find(params[:security_permission][:config_panel_submodule_id])
    @action_methods = eval(@submodule.controller_module).action_methods
		@default_actions = AppConfig.default_acctions_controller
  end

end
