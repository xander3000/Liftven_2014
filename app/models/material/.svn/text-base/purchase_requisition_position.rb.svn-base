class Material::PurchaseRequisitionPosition < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:quantity => " Ctd. pedido",
												:verified_quantity => " Ctd. pedido verificado",
												:approved_quantity => " Ctd. pedido aprobado",
												:verified_by => "Verificado por",
												:approved_by => "Aprobado por",
												:material_raw_material => "Material",
												:reason => "Motivo",
                        :material_order_measure_unit => "Unidad",
												:material_purchase_requisition_position_status_type => "Estatus"

	validates_presence_of :material_raw_material,
												:quantity,
											  :material_order_measure_unit,
												:reason

	validates_numericality_of :quantity,:greater_than => 0
	validates_presence_of :material_purchase_requisition_position_status_type


	belongs_to :material_purchase_requisition,:class_name => "Material::PurchaseRequisition"
	belongs_to :verified_by,:class_name => "User"
	belongs_to :approved_by,:class_name => "User"
	belongs_to :material_raw_material,:class_name => "Material::RawMaterial"
  belongs_to :material_order_measure_unit,:class_name => "Material::MeasureUnit"
	belongs_to :material_purchase_requisition_position_status_type,:class_name => "Material::PurchaseRequisitionPositionStatusType"
	has_one			:material_quotation_requisition_position,:class_name => "Material::QuotationRequisitionPosition",:foreign_key => "material_purchase_requisition_position_id"
	


	#
	# Seta los valores de las catidades acorde al estatus
	#
	def set_quantity_values
		
		if material_purchase_requisition_position_status_type.is_register?
			update_attributes!(:verified_quantity => quantity)
		elsif material_purchase_requisition_position_status_type.is_verify?
			update_attributes!(:approved_quantity => verified_quantity)
		end
	end

	#
	# Aprobdas por cotizar
	#
	def self.all_approved
		all(:conditions => ["material_purchase_requisition_position_status_types.tag_name = ?",Material::PurchaseRequisitionPositionStatusType::APPROVED],:include => :material_purchase_requisition_position_status_type)
	end

end
