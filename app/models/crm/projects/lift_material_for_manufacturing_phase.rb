class Crm::Projects::LiftMaterialForManufacturingPhase < ActiveRecord::Base
		def self.table_name_prefix
    'crm_projects_'
  end

		attr_accessor :material_raw_material_name,
									:id_temporal

		humanize_attributes :material_raw_material => "Material/Insumos",
												:material_raw_material_name => "Material/Insumos",
												:quantity => "Cantidad",
												:crm_projects_lift_manufacturing_phase => "Fase"


	belongs_to :material_raw_material,:class_name => "Material::RawMaterial"
	belongs_to :crm_projects_lift_manufacturing_phase,:class_name => "Crm::Projects::LiftManufacturingPhase"
	belongs_to :crm_projects_lift_model,:class_name => "Crm::Projects::LiftModel"
	
	validates_presence_of :crm_projects_lift_manufacturing_phase,:material_raw_material,:quantity
end
