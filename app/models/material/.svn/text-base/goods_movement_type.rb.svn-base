class Material::GoodsMovementType < ActiveRecord::Base
	def self.table_name_prefix
    'material_'
  end
	IN_GOODS_MOVEMENT = "in_goods_movement"
  OUT_GOODS_MOVEMENT = "out_goods_movement"
	has_many :material_goods_movement_reasons,:class_name => "Material::GoodsMovementReason",:foreign_key => "material_goods_movement_type_id"
end
