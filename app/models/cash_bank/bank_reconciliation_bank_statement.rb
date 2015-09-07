class CashBank::BankReconciliationBankStatement < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end


		humanize_attributes	:date => "Fecha",
												:reference => "Referencia",
												:debit_amount => "Debito",
												:credit_amount => "Credito",
												:description => "Descripción",
												:balance => "Saldo",
												:movement_operation => "Tipo de movimiento"

	belongs_to :cash_bank_bank_reconciliation,:class_name => "CashBank::BankReconciliation"
end
