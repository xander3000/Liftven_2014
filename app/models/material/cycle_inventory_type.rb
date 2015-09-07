class Material::CycleInventoryType < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end
end
