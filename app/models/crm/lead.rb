class Crm::Lead < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end

	 humanize_attributes :first_name => "Nombre",
													:last_name => "Apellido",
													:salulation => "Saludos",
													:title => "Titulo",
													:crm_account => "Cuenta",
													:principal_email => "Correo principal",
													:alternative_email => "Correo alternativo",
													:office_phone => "Teléfono oficina",
													:assigned_to => "Asignada a",
													:created_at => "Creado el",
													:cellphone => "Teléfono movil",
													:department => "Departamento",
													:do_not_call => "No llamar",
													:primary_address => "Direccion prinicpal",
													:fax => "Fax",
													:report_to => "Reporta a",
													:crm_lead_source => "Fuente de Posible cliente",
													:description => "Descripción",
													:crm_lead_status_type => "Estatus"


	validates_presence_of :name,:crm_lead_status_type,:assigned_to,:principal_email

	belongs_to :crm_lead_status_type,:class_name => "Crm::LeadStatusType"
	belongs_to :report_to,:class_name => "Crm::Contact"
	belongs_to :crm_lead_source,:class_name => "Crm::LeadSource"
	belongs_to :assigned_to,:class_name => "Payroll::Employee",:conditions => ["payroll_position_id = ?",32]
	belongs_to :salulation
	belongs_to :crm_account,:class_name => "Crm::Account"


	#
	# Nombre compuesto por fisrt_Name y last_name
	#
	def name
		"#{(salulation ? salulation.name : "")} #{first_name} #{last_name}"
	end

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Contacto de negocios"
	end
end
