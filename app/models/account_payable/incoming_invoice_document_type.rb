class AccountPayable::IncomingInvoiceDocumentType < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end

	DIRECT_PAYMENT = "direct_payment"
	PURCHASE_ORDEN = "purchase_oden"


	#
	# Nombrte (id-tag)
	#
	def fullname
		"#{id.to_code("02")}-#{tag_name}"
	end
end
