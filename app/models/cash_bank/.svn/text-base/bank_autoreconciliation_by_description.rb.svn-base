class CashBank::BankAutoreconciliationByDescription < ActiveRecord::Base
		def self.table_name_prefix
    'cash_bank_'
  end
		belongs_to :cash_bank_bank,:class_name => "CashBank::Bank"
end
