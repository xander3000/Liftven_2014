class CashBank::DailyCashOpening < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end
	belongs_to :cash_bank_cash,:class_name => "CashBank::Cash"
	has_one :cash_bank_daily_cash_closing,:class_name => "CashBank::DailyCashClosing",:foreign_key => :cash_bank_daily_cash_opening_id

	validates_uniqueness_of :date

end
