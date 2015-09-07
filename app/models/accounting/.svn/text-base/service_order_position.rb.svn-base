class Accounting::ServiceOrderPosition < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end
	humanize_attributes		:quantity => " Ctd. pedido",
												:concept => "Concepto/Descripción",
												:delivery_date => "Fecha entrega",
												:sub_total => "Sub Total",
												:total => "Total"

	belongs_to :accounting_service_order,:class_name => "Accounting::ServiceOrder"

	before_save :set_value_total
  
  	#
	# Seteal el valor de total en base al sub_total y quantity
	#
	def set_value_total
		self.total = self.sub_total * self.quantity
	end
end
