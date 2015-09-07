class AccountPayable::IncomingInvoicePosition < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end
  attr_accessor :id_temporal
  humanize_attributes	:quantity => " Ctd. pedido",
												:material_raw_material => "Material",
												:material_order_measure_unit => "Unidad",
												:sub_total => "Precio unitario",
												:tax => "% alicuota IVA",
												:tax_amount => "IVA",
												:taxable => "Sub total",
												:total => "Total",
												:description => "Material / Descripción"
	belongs_to :account_payable_incoming_invoice,:class_name => "AccountPayable::IncomingInvoice"
	belongs_to	:material_raw_material,:class_name => "Material::RawMaterial"
	belongs_to :material_order_measure_unit,:class_name => "Material::MeasureUnit"
	belongs_to :tax

	validates_presence_of :quantity,
												:sub_total,
												:total,
												:description,
												:material_order_measure_unit,
                        :tax,
                        :tax_amount
end
