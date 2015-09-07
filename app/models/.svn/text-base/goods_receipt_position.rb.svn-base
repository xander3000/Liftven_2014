class GoodsReceiptPosition < ActiveRecord::Base
	humanize_attributes		:packing_material => "Unidad",
												:quantity => " Ctd. pedido",
												:raw_material => "Material",
												:delivery_date => "Fecha entrega"

	validates_presence_of :raw_material,
												:quantity,
												:packing_material


	belongs_to :goods_receipt
	belongs_to	:packing_material
	belongs_to	:raw_material#,:class_name => "Material::RawMaterial"






end
