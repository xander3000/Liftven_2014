class PresentationUnitTypeConversion < ActiveRecord::Base
  belongs_to :presentation_unit_type_from,:class_name => "PresentationUnitType"#,:foreign_key => "presentation_unit_type_from_id"
  belongs_to :presentation_unit_type_to,:class_name => "PresentationUnitType"#,:foreign_key => "presentation_unit_type_to_id"
end
