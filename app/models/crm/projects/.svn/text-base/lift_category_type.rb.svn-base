class Crm::Projects::LiftCategoryType < ActiveRecord::Base
  def self.table_name_prefix
    'crm_projects_'
  end
	has_many :crm_projects_lift_models,:class_name => "Crm::Projects::LiftModel",:foreign_key => "crm_projects_lift_category_type_id"
end
