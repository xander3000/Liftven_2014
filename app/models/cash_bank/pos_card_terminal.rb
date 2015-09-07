class CashBank::PosCardTerminal < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	belongs_to :cash_bank_bank_account,:class_name => "CashBank::BankAccount"
	#
	#
	#
	def name
		cash_bank_bank_account.name
	end

	#
	# Todos los POS menos lo incluidos
	#
	def self.all_not_included(pos_card_terminal_includes)
		self.all(:conditions => ["id NOT IN (?)",pos_card_terminal_includes])
	end
end
