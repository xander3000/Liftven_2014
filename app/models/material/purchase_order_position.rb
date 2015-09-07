class Material::PurchaseOrderPosition < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:quantity => " Ctd. pedido",
												:material_raw_material => "Material",
												:delivery_date => "Fecha entrega",
                        :material_order_measure_unit => "Unidad",
												:sub_total => "Sub Total",
												:total => "Total"

	validates_presence_of :material_raw_material,
												:quantity,
												:sub_total,
                        :material_order_measure_unit,
												:total


	belongs_to :material_purchase_order,:class_name => "Material::PurchaseOrder"
	belongs_to	:material_raw_material,:class_name => "Material::RawMaterial"
  belongs_to :material_order_measure_unit,:class_name => "Material::MeasureUnit"
	before_save :set_value_total
	

	#
	# Seteal el valor de total en base al sub_total y quantity
	#
	def set_value_total
		self.total = self.sub_total * self.quantity
	end
end
