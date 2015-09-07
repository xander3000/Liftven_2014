class Accounting::WithholdingTaxeType < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end
  humanize_attributes		:name => "Nombre",
                        :code => "Código",
                        :is_natural => "¿Redtención Persona Natural?",
                        :percentage => "Porcentaje"


	#
	# Nombre  y procentaje
	#
	def full_name
		"#{code} - #{name} (#{percentage}%)"
	end

	#
	# Nombre con codigo
	#
	def fullname
		"#{code} - #{name}"
	end

	#
	# Nombre con codigo
	#
	def name_with_person_type
		"#{name} (P#{is_natural ? 'N':'J'})"
	end

	#
	# Busca todos los tipos acorde al tipo de documento
	#
	def self.all_by_identification_document_type(identification_document_type,options={})
		options[:ignore] ||= []

		clausules = []
		values = []
		conditions  = []

		type = IdentificationDocumentType.find_by_short_name(identification_document_type)

		clausules << "is_natural = ?"
		values <<  type.is_natural
		if !options[:ignore].empty?
			clausules << "id NOT IN (?)"
			values <<  options[:ignore]
		end
		
		conditions << clausules.join(" AND ")
		conditions.concat( values )

		all(:conditions => conditions,:order => "code asc")
	end

end