class AccountPayable::StatusIncomingInvoice < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end
	belongs_to :account_payable_incoming_invoice_status_type,:class_name => "AccountPayable::IncomingInvoiceStatusType"
	belongs_to :account_payable_incoming_invoice,:class_name => "AccountPayable::IncomingInvoice",:foreign_key => "account_payable_incoming_invoice_id"
	belongs_to :create_by,:class_name => "User"

	before_create :set_with_actual


	#
	# Define el status como el actual
	#
	def set_with_actual
		account_payable_incoming_invoice.account_payable_status_incoming_invoices.all.each do |status|
			status.update_attribute(:actual, false)
		end
	end

end
