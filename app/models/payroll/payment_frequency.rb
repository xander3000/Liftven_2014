class Payroll::PaymentFrequency < ActiveRecord::Base
	
	AMBAS_QUINCENAS = "ambas_quincenas"
	PRIMERA_QUINCENA = "primera_quincena"
	SEGUNDA_QUINCENA = "segunda_quincena"

	def self.table_name_prefix
    'payroll_'
  end
end