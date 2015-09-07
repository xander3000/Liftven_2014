class Crm::Projects::CallManagerRegister < ActiveRecord::Base
	def self.table_name_prefix
    'crm_projects_'
  end

	humanize_attributes :crm_project => "Proyecto",
											:phone => "Telefono local / celular",
											:comment => "Comentario",
											:next_call_date => "Siguiente fecha llamada",
											:next_call_time => "Siguiente hora llamada"

	belongs_to :crm_project,:class_name => "Crm::Project"

	validates_presence_of :phone,:comment

end
