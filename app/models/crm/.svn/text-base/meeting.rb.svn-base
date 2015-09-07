class Crm::Meeting < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end


	attr_accessor :related_to_name

	humanize_attributes		:subject => "Asunto",
												:assigned_to => "Asignada a",
												:description => "Descripcción",
												:crm_contact => "Contacto",
												:crm_meeting_type => "Tipo de reunión",
												:related_to_type => "Tipo de relación",
												:related_to => "Relacionado a",
												:related_to_id => "Relacionado a",
												:related_to_name => "Relacionado a",
												:start_date => "Fecha de inicio",
												:start_time => "Hora de inicio",
												:reminders_popup => "Recordar con ventana emergente",
												:email_all_invitees => "Enviar correos a todos los invitados",
												:duration_hours => "Duración en horas",
												:location => "Ubicación",
												:created_at => "Creado el"



	validates_presence_of :subject,:related_to_id,:related_to_name,:related_to_type,:start_date,:start_time,:duration_hours,:assigned_to,:crm_meeting_type

	belongs_to :crm_account_type,:class_name => "Crm::AccountType"
	belongs_to :crm_sector_account_type,:class_name => "Crm::SectorAccountType"
	belongs_to :crm_contact,:class_name => "Crm::Contact"
	belongs_to :assigned_to,:class_name => "User"
	belongs_to :crm_meeting_type,:class_name => "Crm::MeetingType"
	belongs_to :related_to,:polymorphic => true


	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Reunión"
	end

	#
	# Nombre dela relacion
	#
	def related_to_name
		related_to.name if related_to
	end

end
