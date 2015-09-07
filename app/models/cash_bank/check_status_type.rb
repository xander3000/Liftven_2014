class CashBank::CheckStatusType < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end
end
