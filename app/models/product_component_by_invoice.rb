class ProductComponentByInvoice < ActiveRecord::Base
  attr_accessor :id_temporal
  belongs_to :element,:polymorphic => true
  belongs_to :product_by_invoice
  belongs_to :product_component_type


  validates_presence_of :product_component_type,:element
end
