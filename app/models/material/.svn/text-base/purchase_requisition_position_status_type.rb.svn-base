class Material::PurchaseRequisitionPositionStatusType < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	REGISTER = "reg"
	VERIFY = "rev"
	CANCEL = "anu"
	APPROVED = "apr"
	RETURNED = "dev"
	QUOTATION = "cot"



	#
	# Estado de verificar
	#
	def self.default
		first(:conditions => {:default => true})
	end


	#
	# Es una estadi de registro
	#
	def is_register?
		tag_name.eql?(REGISTER)
	end
	
	#
	# Es una estado de revision
	#
	def is_verify?
		tag_name.eql?(VERIFY)
	end



	#
	# Todos los estado spar validar
	#
	def self.all_for_verify
		all(:conditions => ["tag_name IN (?)",[VERIFY,RETURNED]])
	end

	#
	# Todos los estado spar apropbar
	#
	def self.all_for_approve
		all(:conditions => ["tag_name IN (?)",[APPROVED,RETURNED]])
	end

end
