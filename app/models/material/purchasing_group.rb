class Material::PurchasingGroup < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end
end
