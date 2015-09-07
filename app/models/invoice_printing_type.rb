class InvoicePrintingType < ActiveRecord::Base
	FISCAL = "fiscal"
	LIBRE = "libre"

	has_many :invoices


	#
	# impresoreas que pueden imprimir ISLR
	#
	def can_print_islr?
		InvoicePrintingType.print_islr_allowed.include?(tag_name)
	end

	#
	# Listaod e impresoras para ISLR
	#
	def self.print_islr_allowed
		[LIBRE]
	end
end
