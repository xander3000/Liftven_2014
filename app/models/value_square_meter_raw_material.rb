class ValueSquareMeterRawMaterial < ActiveRecord::Base
  humanize_attributes :base_value => "Valor base"
  
  belongs_to :raw_material#,:class_name => "Material::RawMaterial"
end
