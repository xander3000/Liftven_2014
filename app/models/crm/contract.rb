class Crm::Contract < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end

	 humanize_attributes :name => "Nombre",
												:website => "Sito Web",
												:crm_account => "Cuenta",
												:assigned_to => "Asignada a",
												:crm_contract_status_type => "Estatus",
												:crm_opportunity => "Oportunidad",
												:description => "Descripcción",
												:start_date => "Fecha de inicio",
												:end_date => "Fecha fín",
												:reference_code => "Código de referencia",
												:created_at => "Creado el"


	belongs_to :crm_account,:class_name => "Crm::Account"
	belongs_to :crm_contract_status_type,:class_name => "Crm::ContractStatus"
	belongs_to :assigned_to,:class_name => "User"
	belongs_to :crm_opportunity,:class_name => "Crm::Opportunity"

	validates_presence_of  :name,:crm_account,:crm_contract_status_type,:assigned_to

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Contrato"
	end
end
