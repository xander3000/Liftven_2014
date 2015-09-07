class Material::QuotationRequisition < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Cotizacion de pedido",
												:note => "Observacion",
												:material_quotation_requisition_position_positions => "Posiciones",
												:completed => "¿Cotizado completo?",
                        :material_purchase_requisition => "Orden de pedido"

	belongs_to :create_by,:class_name => "User"
  belongs_to :material_purchase_requisition,:class_name => "Material::PurchaseRequisition"
	has_many :material_quotation_requisition_position_positions,:class_name => "Material::QuotationRequisitionPosition",:foreign_key => "material_quotation_requisition_id"
  

	validates_presence_of :posting_date,:delivery_date,:create_by

  after_create :set_to_complete


	#
	# Todas por licitacion
	#
	def all_by_tender
		material_quotation_requisition_position_positions.all(:conditions => ["material_quotation_requisition_position_status_types.tag_name = ?",Material::QuotationRequisitionPositionStatusType::QOUTED],:include => [:material_quotation_requisition_position_status_type])
	end

  #
  # Busca cotizaciones actuales
  #
  def self.new_not_completed(attr={})
    object = first(:conditions => {:completed => false})
    object ? object : new(attr)
  end
  
  #
  # valida si la cotizacion es ediyttable
  #
  def can_edit?
    !completed
  end
  
  #
  #
  #
  def set_to_complete
    if material_quotation_requisition_position_positions.empty?
      complete = false
    else
      complete = true
    end
    material_quotation_requisition_position_positions.each do |position|
      status_type = position.material_quotation_requisition_position_status_type
      complete &= status_type.is_qouted?
    end
      update_attribute(:completed,complete)
  end


	#
	# Puede seleccionar mejor proveedor
	#
	def can_select_best_supplier?
		complete = true
		material_quotation_requisition_position_positions.each do |position|
      status_type = position.material_quotation_requisition_position_status_type
      complete &= status_type.is_qouted?
    end
		complete and completed
	end

	#
	# Subtotal de la cotizacion con mejor proveedor
	#
	def sub_total
			0.0
	end

	#
	# Impuesto de la cotizacion con mejor proveedor
	#
	def tax
		0.0
	end

	#
	# Total de la cotizacion con mejor proveedor
	#
	def total
		0.0
	end

end
