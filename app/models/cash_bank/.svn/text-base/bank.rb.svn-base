class CashBank::Bank < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :format_check

	humanize_attributes		:base => "Banco",
												:code => "Codigo bancario",
												:name => "Nombre",
												:fullname => "Nombre completo",
												:format_check => "Formato cheque"

	has_many :cash_bank_bank_accounts,:class_name => "CashBank::BankAccount",:foreign_key => "cash_bank_bank_id"
	has_many :cash_bank_bank_autoreconciliation_by_descriptions,:class_name => "CashBank::BankAutoreconciliationByDescription",:foreign_key => "cash_bank_bank_id"
	
	validates_presence_of :code,:name,:fullname
	validates_uniqueness_of :code
end
