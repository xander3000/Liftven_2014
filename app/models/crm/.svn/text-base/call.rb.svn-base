class Crm::Call < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end

	attr_accessor :related_to_name

	humanize_attributes		:subject => "Asunto",
												:assigned_to => "Asignada a",
												:description => "Descripcción",
												:related_to_type => "Tipo de relación",
												:related_to => "Relacionado a",
												:related_to_id => "Relacionado a",
												:related_to_name => "Relacionado a",
												:start_date => "Fecha de inicio",
												:start_time => "Hora de inicio",
												:reminders_popup => "Recordar con ventana emergente",
												:email_all_invitees => "Enviar correos a todos los invitados",
												:duration_hours => "Duración en horas",
												:created_at => "Creado el"



	validates_presence_of :subject,:related_to_id,:related_to_name,:related_to_type,:start_date,:start_time,:duration_hours,:assigned_to

	belongs_to :crm_account_type,:class_name => "Crm::AccountType"
	belongs_to :crm_sector_account_type,:class_name => "Crm::SectorAccountType"
	belongs_to :assigned_to,:class_name => "User"
	belongs_to :member_of,:class_name => "User"
	belongs_to :related_to,:polymorphic => true


	#
	# Nombre dela relacion
	#
	def related_to_name
		related_to.name if related_to
	end
end
