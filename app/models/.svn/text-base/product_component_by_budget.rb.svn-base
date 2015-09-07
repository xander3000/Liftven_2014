class ProductComponentByBudget < ActiveRecord::Base
  attr_accessor :id_temporal
  belongs_to :product_by_budget
  belongs_to :product_component_type
  belongs_to :element,:polymorphic => true
  validates_presence_of :product_component_type,:element
end
