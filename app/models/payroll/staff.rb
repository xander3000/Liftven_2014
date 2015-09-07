class Payroll::Staff < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end
  
  attr_accessor :contact_fullname
   

	humanize_attributes  :fullname => "Nombre",
												:identification_document => "Doc. Identificación",
                        :rif => "R.I.F.",
												:first_name => "Primer Nombre",
												:last_name => "Primer Apellido",
												:second_name => "Segundo Nombre",
												:second_last_name => "Segundo Apellido",
												:email => "Correo electrónico",
												:birthday => "F. Nacimiento",
												:payroll_gender => "Sexo",
                        :cellphone => "Celular",
                        :telephone => "telefono"



	belongs_to :payroll_gender,:class_name => "Payroll::Gender"
  
	validates_presence_of :identification_document,:rif,:first_name,:last_name,:email,:birthday,:payroll_gender
	validates_uniqueness_of :identification_document,:email
	validates_uniqueness_of :rif,:if => Proc.new { |staff| !staff.rif.eql?("N/P") }

	#
	# Fullname
	#
	def fullname
		"#{first_name} #{last_name}"
	end

	#
	# Complete Fullname
	#
	def complete_fullname
		"#{first_name} #{second_name} #{last_name} #{second_last_name}"
	end

	#
	# Es masculino
	#
	def is_male?
		payroll_gender.tag_name.eql?("M")
	end
end
