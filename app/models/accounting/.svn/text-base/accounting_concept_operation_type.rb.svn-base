class Accounting::AccountingConceptOperationType < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end

	MBE = "mbe"

	belongs_to :accounting_ledger_type,:class_name => "Accounting::LedgerType"

end
