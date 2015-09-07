class Payroll::HistoricalPayroll < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end
	belongs_to :payroll_concept_personal_type,:class_name => "Payroll::ConceptPersonalType"
	belongs_to :payroll_employee,:class_name => "Payroll::Employee",:foreign_key => "payroll_employee_id"
	belongs_to :payroll_payment_frequency,:class_name => "Payroll::PaymentFrequency"
	belongs_to :payroll_regular_payroll_check,:class_name => "Payroll::RegularPayrollCheck"
end