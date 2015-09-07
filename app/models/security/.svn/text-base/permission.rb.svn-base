class Security::Permission < ActiveRecord::Base
  def self.table_name_prefix
    'security_'
  end

  humanize_attributes		:action_name => "Nombre accion",
                        :security_role => "Perfil",
                        :config_panel_submodule => "Submódulo",
												:config_panel_module => "Módulo"

  belongs_to :config_panel_module,:class_name => "ConfigPanel::Module",:foreign_key => "config_panel_module_id"
	belongs_to :config_panel_submodule,:class_name => "ConfigPanel::Submodule",:foreign_key => "config_panel_submodule_id"
  belongs_to :security_role,:class_name => "Security::Role",:foreign_key => "security_role_id"

  validates_presence_of :config_panel_module,:config_panel_submodule,:security_role

end
