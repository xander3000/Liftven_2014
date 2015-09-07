class Material::PurchaseRequisition < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Pedido de compra",
												:note => "Observación",
												:material_purchase_requisition_status_type => "Estatus"


	belongs_to :create_by,:class_name => "User"
	belongs_to :material_purchase_requisition_status_type,:class_name => "Material::PurchaseRequisitionStatusType"
	has_many :material_purchase_requisition_positions,:class_name => "Material::PurchaseRequisitionPosition",:foreign_key => "material_purchase_requisition_id"
	has_many :material_registered_purchase_requisition_positions,:class_name => "Material::PurchaseRequisitionPosition",:foreign_key => "material_purchase_requisition_id",:conditions => ["material_purchase_requisition_position_status_types.tag_name = ?",Material::PurchaseRequisitionPositionStatusType::REGISTER],:include => [:material_purchase_requisition_position_status_type]
	has_many :material_verified_purchase_requisition_positions,:class_name => "Material::PurchaseRequisitionPosition",:foreign_key => "material_purchase_requisition_id",:conditions => ["material_purchase_requisition_position_status_types.tag_name = ?",Material::PurchaseRequisitionPositionStatusType::VERIFY],:include => [:material_purchase_requisition_position_status_type]
	has_many :material_approved_purchase_requisition_positions,:class_name => "Material::PurchaseRequisitionPosition",:foreign_key => "material_purchase_requisition_id",:conditions => ["material_purchase_requisition_position_status_types.tag_name = ?",Material::PurchaseRequisitionPositionStatusType::APPROVED],:include => [:material_purchase_requisition_position_status_type]

	validates_presence_of :delivery_date


  
  #
  # Codigo
  #
  def code
     "OP-"+"%05d" % id
  end
  
  
  #
  # Nombre descripctivo
  #
  def name
    "#{code}"
  end

  #
	# Es eregistrada
	#
	def is_register?
		material_purchase_requisition_status_type.tag_name.eql?(Material::PurchaseRequisitionPositionStatusType::REGISTER)
	end
	
  #
	# Es revisada
	#
	def is_verify?
		material_purchase_requisition_status_type.tag_name.eql?(Material::PurchaseRequisitionPositionStatusType::VERIFY)
	end


	  #
	# Es revisada
	#
	def is_approve?
		material_purchase_requisition_status_type.tag_name.eql?(Material::PurchaseRequisitionPositionStatusType::APPROVED)
	end

  #
  # Todas las apobadas
  # 
  def approved
    positions = []
    material_purchase_requisition_positions.each do |position|
      positions << position if position.material_purchase_requisition_position_status_type.tag_name.eql?(Material::PurchaseRequisitionPositionStatusType::APPROVED)
    end
    positions
  end
   
  
  
	#
	# Retorna true si fueron agragdos position al purchase
	#
	def has_added_item_positions?(purchase_requisition_positions_added)
		if purchase_requisition_positions_added.empty?
			 errors.add_to_base("debe seleccionar al menos un material")
			 false
		end
		true
	end

	#
	# Pedids segun usuario
	#
	def self.all_owner(user)
		all(:conditions => ["create_by_id = ?",user.id])
	end
end
