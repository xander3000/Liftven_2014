class AccesoryComponentByInvoice < ActiveRecord::Base
  attr_accessor :id_temporal
  belongs_to :product_by_invoice
  belongs_to :accessory_component_type
end
