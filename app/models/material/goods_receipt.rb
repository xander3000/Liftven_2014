class Material::GoodsReceipt < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	humanize_attributes	  :material_purchase_order => "Pedido",
												:supplier => "Proveedor",
												:create_by => "Creado por",
												:delivery_date => "Fecha estima de entrega",
												:posting_date => "Contabilización",
												:base => "Movimiento de mercancia"

	belongs_to :material_purchase_order,:class_name => "Material::GoodsMovementPurchaseOrder"
	belongs_to :supplier
	belongs_to :create_by,:class_name => "User"

	has_many :material_goods_receipt_positions,:class_name => "Material::GoodsMovementPosition"

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
