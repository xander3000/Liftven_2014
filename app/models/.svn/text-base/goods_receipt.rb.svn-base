class GoodsReceipt < ActiveRecord::Base
	humanize_attributes	  :purchase_order => "Pedido",
												:supplier => "Proveedor",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Movimiento de mercancia"

	belongs_to :purchase_order
	belongs_to :supplier
	belongs_to :create_by,:class_name => "User"
	belongs_to :location_inventory
	has_many :goods_receipt_positions

	validates_presence_of :supplier,
												:create_by,
												:posting_date

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

end
