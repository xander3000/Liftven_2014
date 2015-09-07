class Material::GoodsMovement < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end

		attr_accessor :supplier_name

		humanize_attributes	:material_purchase_order => "Order de compra",
												:supplier => "Proveedor",
												:supplier_name => "Proveedor",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Movimiento de mercancia",
												:material_goods_movement_type => "Tipo de movimiento",
												:material_goods_movement_reason => "Razon del movimiento",
												:doc => "Documento afectado",
												:doc_type => "Tipo de documento afectado"

	belongs_to :material_goods_movement_type,:class_name => "Material::GoodsMovementType",:foreign_key => "material_goods_movement_type_id"
	belongs_to :material_goods_movement_reason,:class_name => "Material::GoodsMovementReason",:foreign_key => "material_goods_movement_reason_id"
	belongs_to :doc,:polymorphic => true
	belongs_to :supplier
	belongs_to :create_by,:class_name => "User"
	has_many :material_goods_movement_positions,:class_name => "Material::GoodsMovementPosition",:foreign_key => "material_goods_movement_id"

	validates_presence_of :create_by,
												:posting_date,
												:material_goods_movement_type,
												:material_goods_movement_reason,
												:doc
	validates_uniqueness_of :doc_id,:scope => [:doc_type,:material_goods_movement_type_id]



	#
	# Retorna true si fueron agragdos position al purchase
	#
	def has_added_item_positions?(goods_receipt_positions_added)
		if goods_receipt_positions_added.empty?
			 errors.add_to_base("debe seleccionar al menos un material")
			 return false
		end
		true
	end

	#
	# Verifica si para cada posicion el material hay en stock
	#
	def has_raw_material_stock_item_positions?(goods_receipt_positions_added)
		success = true
		if material_goods_movement_type and material_goods_movement_type.tag_name.eql?(Material::GoodsMovementType::OUT_GOODS_MOVEMENT)
			goods_receipt_positions_added.each do |position|
				if position.material_raw_material.unrestricted_use_stock < position.quantity
					errors.add_to_base("no hay stock disponible para #{position.material_raw_material.name}")
					success = false
				end
			end
		end
		success
	end



	#
	# Nombre del proveedor
	#
	def supplier_name
		supplier.name if supplier
	end

  #
  # Aumentar o dismunir inventario
  #
  def update_stock_by_raw_material

    material_goods_movement_positions.each do |goods_movement_position|
      unrestricted_use_stock = goods_movement_position.material_raw_material.unrestricted_use_stock
			restricted_use_stock = goods_movement_position.material_raw_material.restricted_use_stock
      if material_goods_movement_type.tag_name.eql?(Material::GoodsMovementType::IN_GOODS_MOVEMENT)
        goods_movement_position.material_raw_material.update_attribute(:unrestricted_use_stock,unrestricted_use_stock+goods_movement_position.quantity)
      else
        goods_movement_position.material_raw_material.update_attributes(:unrestricted_use_stock =>(unrestricted_use_stock-goods_movement_position.quantity),:restricted_use_stock => (restricted_use_stock+goods_movement_position.quantity)) #(:unrestricted_use_stock,unrestricted_use_stock-goods_movement_position.quantity)
      end
    end
  end
end