class Material::QuotationRequisitionPositionStatusType < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	REGISTER = "reg"
	QOUTED = "cot"
	TENDERED = "lic"
	COMPROMISED = "com"
	


	#
	# Es una estadi de registro
	#
	def is_register?
		tag_name.eql?(REGISTER)
	end

	#
	# Es una estado de cotizado
	#
	def is_qouted?
		tag_name.eql?(QOUTED)
	end

	#
	# Es una estado de licitado
	#
	def is_tendered?
		tag_name.eql?(TENDERED)
	end
	#
	# Es una estado de licitado
	#
	def is_compromised?
		tag_name.eql?(COMPROMISED)
	end


	
end
