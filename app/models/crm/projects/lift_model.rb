class Crm::Projects::LiftModel < ActiveRecord::Base
	def self.table_name_prefix
    'crm_projects_'
  end

	named_scope :all_by_category, lambda { |tag_name|  { :conditions => [],:order => "crm_projects_lift_category_type_id ASC" }}

	humanize_attributes  :crm_projects_lift_category_type => "Categoría",
											:name => "Nombre",
											:crm_projects_lift_manufacturing_phases => "Fases"


	belongs_to :crm_projects_lift_category_type,:class_name => "Crm::Projects::LiftCategoryType"
	has_many :crm_projects_lift_manufacturing_phase_lift_models,:class_name => "Crm::Projects::LiftManufacturingPhaseLiftModel",:foreign_key => "crm_projects_lift_model_id",:order => "id"
	has_many :crm_projects_lift_manufacturing_phases,:class_name => "Crm::Projects::LiftManufacturingPhase",:through => :crm_projects_lift_manufacturing_phase_lift_models
	has_many 	:crm_projects_lift_material_for_manufacturing_phases,:class_name => "Crm::Projects::LiftMaterialForManufacturingPhase",:foreign_key => "crm_projects_lift_model_id"


	validates_presence_of :name, :crm_projects_lift_category_type,:crm_projects_lift_manufacturing_phases
	validates_uniqueness_of :name,:scope => [:crm_projects_lift_category_type_id]

	#
	# MAteriale spor fase
	#
	def lift_material_for_manufacturing_phases(lift_manufacturing_phase)
		crm_projects_lift_material_for_manufacturing_phases.all(:conditions => {:crm_projects_lift_manufacturing_phase_id => lift_manufacturing_phase.id})
	end
end
