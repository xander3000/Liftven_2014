class Material::GoodsReceiptPosition < ActiveRecord::Base
		def self.table_name_prefix
    'material_'
  end
	humanize_attributes		:quantity => " Ctd. pedido",
												:material_raw_material => "Material",
												:delivery_date => "Fecha entrega"

	validates_presence_of :material_raw_material,
												:quantity
												


	belongs_to :material_goods_receipt
	belongs_to	:material_raw_material,:class_name => "Material::RawMaterial"

end
