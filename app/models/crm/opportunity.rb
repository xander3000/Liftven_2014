class Crm::Opportunity < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end

	 humanize_attributes :name => "Nombre",
											
												:crm_account => "Cuenta",
												:assigned_to => "Asignada a",
												:crm_apportunity_type => "Tipo",
												:crm_opportunity_status_type => "Estatus",
												:description => "Descripcción",
												:crm_lead_source => "Fuente de Posible cliente",
												:expected_revenue => "Ingresos esperados",
												:date_close => "Fecha cierre",
												:probability => "Probabilidad (%)",
												:created_at => "Creado el"


	belongs_to :crm_account,:class_name => "Crm::Account"
	belongs_to :crm_apportunity_type,:class_name => "Crm::OpportunityType"
	belongs_to :crm_opportunity_status_type,:class_name => "Crm::OpportunityStatusType"
	belongs_to :assigned_to,:class_name => "User"
	belongs_to :crm_lead_source,:class_name => "Crm::LeadSource"

	validates_presence_of  :name,:crm_account,:crm_opportunity_status_type,:assigned_to,:crm_apportunity_type,:description,:date_close



	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Oportunidad"
	end
end
