class Crm::Note < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end

	attr_accessor :related_to_name

	humanize_attributes		:subject => "Asunto",
												:assigned_to => "Asignada a",
												:crm_contact => "Contacto",
												:related_to_type => "Tipo de relación",
												:related_to => "Relacionado a",
												:related_to_id => "Relacionado a",
												:related_to_name => "Relacionado a",
												:description => "Descripcción"


	validates_presence_of :subject,:related_to_id,:related_to_name,:related_to_type,:assigned_to,:crm_contact

	belongs_to :crm_contact,:class_name => "Crm::Contact"
	belongs_to :assigned_to,:class_name => "User"
	belongs_to :related_to,:polymorphic => true

	#
	# Nombre dela relacion
	#
	def related_to_name
		related_to.name if related_to
	end

end
