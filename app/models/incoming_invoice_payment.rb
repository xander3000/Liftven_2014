class IncomingInvoicePayment < ActiveRecord::Base
   humanize_attributes  :payment_method_type => "Forma de pago",
                        :transaction_reference => "Referencia de transacción",
                        :transaction_date => "Fecha de transacción",
												:amount => "Monto",
												:created_at => "Fecha contable"

	belongs_to :incoming_invoice
	belongs_to :payment_method_type

	validates_presence_of :payment_method_type,
												:amount

	validates_presence_of :transaction_reference,:transaction_date,:if => Proc.new { |item| item.payment_method_type and item.payment_method_type.require_additional_information }
	validate	:reached_maximum_amount


	#
	# Valida si el amonto actual mas los pagos antyeriores no alncanzal en monto de la factura
	#
	def reached_maximum_amount
		if incoming_invoice.amount_payments.to_f.round(2) + self.amount.to_f.round(2) > incoming_invoice.total.to_f.round(2)
			errors.add(:amount,"execedes el total de la factura:  #{incoming_invoice.amount_payments.to_f.round(2)}/ #{incoming_invoice.total.to_f.round(2)}")
		end
	end
end
