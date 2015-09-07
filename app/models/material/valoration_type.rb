class Material::ValorationType < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end
end
