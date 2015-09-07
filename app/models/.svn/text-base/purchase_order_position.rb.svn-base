class PurchaseOrderPosition < ActiveRecord::Base
	humanize_attributes		:packing_material => "Unidad",
												:quantity => " Ctd. pedido",
												:raw_material => "Material",
												:delivery_date => "Fecha entrega",
												:sub_total => "Sub Total",
												:total => "Total"

	validates_presence_of :raw_material,
												:quantity,
												:packing_material,
												:sub_total,
												:total


	belongs_to :purchase_order
	belongs_to	:packing_material
	belongs_to	:raw_material#,:class_name => "Material::RawMaterial"

	before_save :set_value_total



	#
	# Seteal el valor de total en base al sub_total y quantity
	#
	def set_value_total
		self.total = self.sub_total * self.quantity
	end
	
end
