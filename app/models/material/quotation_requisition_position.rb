class Material::QuotationRequisitionPosition < ActiveRecord::Base
def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:quantity => " Ctd. pedido",
												:material_raw_material => "Material",
												:supplier_1 => "Proveedor 1",
												:supplier_2 => "Proveedor 2",
												:supplier_3 => "Proveedor 3",
												:material_payment_method_type => "Forma de pago",
												:material_quotation_requisition_quality_type => "Calificación",
                        :material_order_measure_unit => "Unidad",
												:sub_total_supplier_1 => "Sub Total Prove. 1",
												:tax_supplier_1 => "IVA Prove. 1",
												:total_supplier_1 =>  "Total Prove. 1",
												:sub_total_supplier_2 =>  "Sub Total Prove. 2",
												:tax_supplier_2 =>  "IVA Prove. 2",
												:total_supplier_2 =>  "Total Prove. 2",
												:sub_total_supplier_3 =>  "Sub Total Prove. 3",
												:tax_supplier_3 =>  "IVA Prove. 3",
												:total_supplier_3 =>  "Total Prove. 3",
												:note => "Observación",
												:selected_supplier => "Proveedor seleccionado"


	validates_presence_of :material_raw_material,
												:quantity,
											  :material_order_measure_unit,
												:supplier_1,
												:sub_total_supplier_1,
												:tax_supplier_1,
												:total_supplier_1
												

	after_create :set_purchase_requisition_position_status_type_to_quotation
	

	validates_numericality_of :quantity,:greater_than => 0



	belongs_to :material_purchase_requisition_position,:class_name => "Material::PurchaseRequisitionPosition"
	belongs_to :material_quotation_requisition,:class_name => "Material::QuotationRequisition"
	belongs_to :material_payment_method_type,:class_name => "Material::PaymentMethodType"
	belongs_to :material_quotation_requisition_quality_type,:class_name => "Material::QuotationRequisitionQualityType"
	belongs_to :material_raw_material,:class_name => "Material::RawMaterial"
  belongs_to :material_order_measure_unit,:class_name => "Material::MeasureUnit"
	belongs_to :supplier_1,:class_name => "Supplier"
	belongs_to :supplier_2,:class_name => "Supplier"
	belongs_to :supplier_3,:class_name => "Supplier"
	belongs_to :selected_supplier,:class_name => "Supplier"
	belongs_to :material_quotation_requisition_position_status_type,:class_name => "Material::QuotationRequisitionPositionStatusType"
	




	#
	# cotiza la posicon en cuestion
	#
	def set_purchase_requisition_position_status_type_to_quotation
		quotation_state = Material::PurchaseRequisitionPositionStatusType.find_by_tag_name(Material::PurchaseRequisitionPositionStatusType::QUOTATION)
		material_purchase_requisition_position.update_attribute(:material_purchase_requisition_position_status_type_id, quotation_state.id)
	end

	#
	# Setear el esttau segun parametros
	#
	def set_status_type
		status_type = material_quotation_requisition_position_status_type
		#if is_register?
		if status_type.is_register?
			if supplier_1_id != nil and supplier_2_id != nil and supplier_3_id != nil
				update_attribute(:material_quotation_requisition_position_status_type_id,Material::QuotationRequisitionPositionStatusType.find_by_tag_name(Material::QuotationRequisitionPositionStatusType::QOUTED).id)
			end
    elsif status_type.is_qouted?
      if supplier_1_id == nil or supplier_2_id == nil or supplier_3_id == nil
				update_attribute(:material_quotation_requisition_position_status_type_id,Material::QuotationRequisitionPositionStatusType.find_by_tag_name(Material::QuotationRequisitionPositionStatusType::REGISTER).id)
			elsif selected_supplier
				update_attribute(:material_quotation_requisition_position_status_type_id,Material::QuotationRequisitionPositionStatusType.find_by_tag_name(Material::QuotationRequisitionPositionStatusType::TENDERED).id)
			end

    end
  end

	#
	# Todas con al menos 1 proveedor faltante
	#
	def self.all_with_a_missing_supplier_or_qouted
		all(:conditions => ["(supplier_1_id IS NULL OR supplier_2_id IS NULL OR supplier_3_id  IS NULL) OR material_quotation_requisition_position_status_types.tag_name  IN (?)",[Material::QuotationRequisitionPositionStatusType::QOUTED,Material::QuotationRequisitionPositionStatusType::REGISTER]],:include => [:material_quotation_requisition_position_status_type])
	end

	#
	# Todas por licitacion
	#
	def self.all_by_tender
		all(:conditions => ["material_quotation_requisition_position_status_types.tag_name = ?",Material::QuotationRequisitionPositionStatusType::QOUTED],:include => [:material_quotation_requisition_position_status_type])
	end
	
end
