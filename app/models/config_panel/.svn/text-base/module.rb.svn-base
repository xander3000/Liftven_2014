class ConfigPanel::Module < ActiveRecord::Base
	def self.table_name_prefix
    'config_panel_'
  end

    humanize_attributes	:name => "Nombre",
                        :tag_name => "Etiqueta",
                        :config_panel_module_category => "Categoría",
                        :orden => "Orden",
                        :icon_path => "Ruta icono",
                        :url => "url",
                        :controller_module => "Controlador del módulo",
                        :description => "Descripción",
                        :active => "¿Activo?"

	belongs_to :config_panel_module_category,:class_name => "ConfigPanel::ModuleCategory",:foreign_key => "config_panel_module_category_id"
	has_many :config_panel_submodules,:class_name => "ConfigPanel::Submodule",:foreign_key => "config_panel_module_id"
	has_many :active_config_panel_submodules,:class_name => "ConfigPanel::Submodule",:foreign_key => "config_panel_module_id",:conditions => {:active => true}

  validates_presence_of :name,:tag_name,:config_panel_module_category,:orden


	def self.all_cpanel
		all(:conditions => {:config_panel_module_category_id => ConfigPanel::ModuleCategory.find_by_tag_name(ConfigPanel::ModuleCategory::CPANEL).id,:active => true},:order => "orden ASC")
	end
end
