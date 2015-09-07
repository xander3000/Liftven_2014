class ProductType < ActiveRecord::Base
  has_and_belongs_to_many :product_component_types,:join_table => "product_component_types_for_product_types"
end
