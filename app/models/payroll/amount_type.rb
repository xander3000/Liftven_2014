class Payroll::AmountType < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

  PORCENTUAL = "porcentual"
  UNITARIA = "unitaria"


end
