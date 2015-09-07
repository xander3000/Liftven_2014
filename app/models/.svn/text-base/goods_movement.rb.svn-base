class GoodsMovement < ActiveRecord::Base
humanize_attributes			:purchase_order => "Pedido",
												:supplier => "Proveedor",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Movimiento de mercancia",
												:goods_movement_type => "Tipo de movimiento",
												:goods_movement_reason => "Razon del movimiento",
												:doc => "Documento afectado"

	belongs_to :goods_movement_type
	belongs_to :goods_movement_reason
	belongs_to :doc,:polymorphic => true
	belongs_to :supplier
	belongs_to :create_by,:class_name => "User"
	belongs_to :location_inventory
	has_many :goods_movement_positions

	validates_presence_of :supplier,
												:create_by,
												:posting_date,
												:goods_movement_type,
												:goods_movement_reason,
												:doc

 


	#
	# Retorna true si fueron agragdos position al purchase
	#
	def has_added_item_positions?(goods_receipt_positions_added)
		if goods_receipt_positions_added.empty?
			 errors.add_to_base("debe seleccionar al menos un material")
			 false
		end
		true
	end

  #
  # Aumentar o dismunir inventario
  #
  def update_stock_by_raw_material

    goods_movement_positions.each do |goods_movement_position|
      unrestricted_use_stock = goods_movement_position.raw_material.unrestricted_use_stock
      if goods_movement_type.tag_name.eql?(GoodsMovementType::IN_GOODS_MOVEMENT)
        goods_movement_position.raw_material.update_attribute(:unrestricted_use_stock,unrestricted_use_stock+goods_movement_position.quantity)
      else
        goods_movement_position.raw_material.update_attribute(:unrestricted_use_stock,unrestricted_use_stock+goods_movement_position.quantity)
      end
    end
  end

end
