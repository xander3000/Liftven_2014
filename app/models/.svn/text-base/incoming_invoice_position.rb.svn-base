class IncomingInvoicePosition < ActiveRecord::Base
		humanize_attributes	:quantity => " Ctd. pedido",
												:raw_material => "Material",
												:packing_material => "Unidad",
												:sub_total => "Sub Total",
												:total => "Total",
												:description => "Ingrese material / Descripción"

	validates_presence_of :quantity,
												:sub_total,
												:total,
												:description


	belongs_to :incoming_invoice
	belongs_to	:raw_material#,:class_name => "Material::RawMaterial"
	belongs_to :packing_material
end
