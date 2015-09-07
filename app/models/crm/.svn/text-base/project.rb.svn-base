class Crm::Project < ActiveRecord::Base
  def self.table_name_prefix
    'crm_'
  end
	attr_accessor :category_type

  humanize_attributes :id => "Documento",
                      :crm_projects_executive => "Ejecutivo",
											:category_type => "Categoria",
                      :entity => "Estado",
                      :city => "Ciudad",
                      :name => "Nombre",
											:address => "Dirección",
											:init_date => "Fecha Inicio",
											:end_date => "Fecha estimada fín",
											:note => "Notas",
											:data_complete => "¿Datos listos?",
											:contribution_amount => "Monto cotización",
											:quote_ready => "¿Cotización lista?",
											:quote_sent => "¿Cotización enviada?",
											:chance => "Probabilidad",
											:approved => "¿Aprobada?",
											:lost => "¿Perdida?",
											:commission => "Comisión",
                      :total_amount => "Monto total"

	belongs_to :client
	belongs_to :crm_projects_executive,:class_name => "Payroll::Employee",:conditions => ["payroll_position_id = ?",32]
	belongs_to :city
	belongs_to :entity
	has_many :crm_projects_lifts,:class_name => "Crm::Projects::Lift",:foreign_key => "crm_project_id"
	has_many :crm_projects_call_manager_registers,:class_name => "Crm::Projects::CallManagerRegister",:foreign_key => "crm_project_id"
	
	validates_presence_of :crm_projects_executive,:entity,:city,:name,:address,:init_date
end
