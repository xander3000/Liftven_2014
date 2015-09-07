class Payroll::EmployeeStatusType < ActiveRecord::Base

	def self.table_name_prefix
    'payroll_'
  end
	ACTIVE = "A"
	GRADUATE = "E"
	REST = "V"
	SUSPENDED = "S"


	#
	#
	#
	def is_graduate?
		tag_name.eql?(GRADUATE)
	end
end
