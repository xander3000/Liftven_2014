class Material::GoodsMovementPosition < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:quantity => " Ctd. pedido",
												:material_raw_material => "Material",
												:delivery_date => "Fecha entrega",
												:material_goods_movement => "Movimieto de mercancia"


	validates_presence_of :material_raw_material,
												:quantity
											


	belongs_to :material_goods_movement,:class_name => "Material::GoodsMovement"
	belongs_to	:material_raw_material,:class_name => "Material::RawMaterial",:foreign_key => "material_raw_material_id"

	after_create :update_raw_material_inventory




	#
	# Actualizar inventario (precio y cantidad) del material
	#
	def update_raw_material_inventory
		aux_quantity = material_goods_movement.material_goods_movement_type.tag_name.eql?(Material::GoodsMovementType::IN_GOODS_MOVEMENT) ? quantity : quantity*-1
		material_raw_material.update_attributes(
																							:unrestricted_use_stock => material_raw_material.unrestricted_use_stock + aux_quantity,
																							:total_stock => material_raw_material.total_stock + aux_quantity,
																							:total_value => (material_raw_material.total_stock + aux_quantity)*material_raw_material.moving_price,
																							:last_price_change => Time.now.to_date,
																							:tax_price_2 => material_raw_material.tax_price_1,
																							:commercial_price_2 => material_raw_material.commercial_price_1,
																							:tax_price_3 => material_raw_material.tax_price_2,
																							:commercial_price_3 => material_raw_material.commercial_price_3,
																							:tax_price_1 => material_raw_material.moving_price,
																							:commercial_price_1 => material_raw_material.moving_price
																						)
	end
end
