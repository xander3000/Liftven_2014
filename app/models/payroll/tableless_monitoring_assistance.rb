class  Payroll::TablelessMonitoringAssistance < ActiveRecord::Base
  has_no_table
	column :employee_fullname, :string
  column :count_weekdays, :float
	column :count_non_weekdays, :float
	column :diff_time_check_in, :float

  
end

