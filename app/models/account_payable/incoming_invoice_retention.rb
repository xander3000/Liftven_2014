class AccountPayable::IncomingInvoiceRetention < ActiveRecord::Base
	def self.table_name_prefix
    'account_payable_'
  end

	 humanize_attributes	:account_payable_incoming_invoice => "Factura",
												:accounting_withholding_taxe_type => "Tipo de retención",
												:percentage => "Porcentaje",
												:subject_retention_amount => "Monto sujeto a retención",
												:retained_amount => "Monto retenido"

	belongs_to :account_payable_incoming_invoice,:class_name => "AccountPayable::IncomingInvoice"
	belongs_to :accounting_withholding_taxe_type,:class_name => "Accounting::WithholdingTaxeType"



	#
	# todos por fecha de purchase_ledger_period de la factura 
	#
	def self.all_by_date(from,to)
		all(:conditions =>  ["account_payable_incoming_invoices.invoice_date >= ? AND account_payable_incoming_invoices.invoice_date <= ?","#{from}","#{to}"],:include => :account_payable_incoming_invoice,:order => "account_payable_incoming_invoices.invoice_date asc" )
	end
end
