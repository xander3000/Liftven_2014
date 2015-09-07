class Material::PurchaseRequisitionStatusType < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	REGISTER = "reg"
	VERIFY = "rev"
	APPROVED = "apr"
	RETURNED = "dev"



	#
	# Estado de verificar
	#
	def self.default
		first(:conditions => {:default => true})
	end

	#
	# Estado de verificar
	#
	def self.verify
		first(:conditions => {:tag_name => Material::PurchaseRequisitionStatusType::VERIFY})
	end

	#
	# Estado de aprobar
	#
	def self.approve
		first(:conditions => {:tag_name => Material::PurchaseRequisitionStatusType::APPROVED})
	end

end
