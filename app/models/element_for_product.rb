class ElementForProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_component_type
  belongs_to :element,:polymorphic => true
  
end
