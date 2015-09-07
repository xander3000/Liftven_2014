class AccountPayable::IncomingInvoiceStatusType < ActiveRecord::Base

	REGISTRADA = "REG"
	APROBADA = "APR"
	RECHAZADA = "REC"
	ANULADA = "ANU"
	PAGO_EMITIDO = "PAG_EMI"
	PAGADA = "PAG"
	REVERSADA = "REV"

	validates_uniqueness_of :tag_name

	def self.table_name_prefix
    'account_payable_'
  end

	#
	# Nombrte (id-tag)
	#
	def fullname
		"#{id.to_code("02")}-#{tag_name}"
	end

	#
	# Estaus defecto
	#
	def self.default
		self.find_by_default(true)
	end
end
