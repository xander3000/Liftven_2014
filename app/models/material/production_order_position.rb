class Material::ProductionOrderPosition < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end
  humanize_attributes   :material_raw_material => "Material",
                        :quantity=> "Cantidad"

	belongs_to :material_production_order,:class_name => "Material::ProductionOrder",:foreign_key => "material_production_order_id"
	belongs_to :material_raw_material,:class_name => "Material::RawMaterial"

	validates_presence_of :quantity,:material_raw_material
	validates_numericality_of :quantity,:greater_than => 0
end
