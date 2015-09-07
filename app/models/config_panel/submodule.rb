class ConfigPanel::Submodule < ActiveRecord::Base
	def self.table_name_prefix
    'config_panel_'
  end

  humanize_attributes	:name => "Nombre",
                      :tag_name => "Etiqueta",
                      :config_panel_module => "Módulo",
                      :orden => "Orden",
                      :icon_path => "Ruta icono",
                      :url => "url",
                      :controller_module => "Controlador del módulo",
                      :description => "Descripción",
                      :active => "¿Activo?"

	belongs_to :config_panel_module,:class_name => "ConfigPanel::Module"
	has_many :security_permissions,:class_name => "Security::Permission",:foreign_key => "config_panel_submodule_id"

  validates_presence_of :name,:tag_name,:config_panel_module,:orden,:url

  def full_name
    "#{config_panel_module.name}/#{name}"
  end
end
