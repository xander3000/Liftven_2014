class PresentationUnitType < ActiveRecord::Base
  has_one  :presentation_unit_type_measure
  has_many :presentation_unit_type_conversions,:foreign_key => "presentation_unit_type_from_id"
  has_many :presentation_unit_type_measurements
end
