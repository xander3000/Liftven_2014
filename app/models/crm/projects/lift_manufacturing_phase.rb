class Crm::Projects::LiftManufacturingPhase < ActiveRecord::Base
		def self.table_name_prefix
    'crm_projects_'
  end
	has_many :crm_projects_lift_material_for_manufacturing_phases,:class_name => "Crm::Projects::LiftMaterialForManufacturingPhase",:foreign_key => "crm_projects_lift_manufacturing_phase_id"
end
