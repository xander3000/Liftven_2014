class Material::MeasureUnit < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end

	humanize_attributes	:name => "Nombre",
											:description => "Descripción"

  validates_presence_of :name
end
