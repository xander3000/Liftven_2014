class AccountPayable::IncomingInvoiceTax < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end
	belongs_to :account_payable_incoming_invoice,:class_name => "AccountPayable::IncomingInvoice"
	belongs_to :tax

	validates_presence_of :account_payable_incoming_invoice,:tax,:tax_amount
end
