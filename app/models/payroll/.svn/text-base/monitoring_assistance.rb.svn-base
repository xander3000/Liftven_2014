class Payroll::MonitoringAssistance < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	attr_accessor :employee_name,
								:employee_document_identificacion

	humanize_attributes		:employee_name => "Nombre del empleado",
												:payroll_employee => "Nombre del empleado",
												:date => "Fecha de entrada",
												:time_check_in => "Hora entrada",
												:time_check_out => "Hora de salida",
												:absent_with_pass => "Ausencia con notificación/permiso",
												:retardation_with_pass => "Retardo con notificación/permiso",
												:extra_time => "Horas extraordinarias"


	belongs_to :payroll_employee,:class_name => "Payroll::Employee",:foreign_key => "payroll_employee_id"


	validates_presence_of :employee_name,
												:payroll_employee,
												:date,
												:time_check_in


	#
	# Nombre del empleado
	#
	def employee_name
		payroll_employee.fullname if payroll_employee
	end


	#
	# Registros por empleado y fecha
	#
	def self.assistances_by_employee(employee,date)
		employee.payroll_monitoring_assistances(:conditions => ["date = ?",date])
	end

		#
	# Registros por fecha determinada
	#
	def self.all_by_date(init_date,end_date)
		all(:conditions => ["date >= ? AND date <= ? AND payroll_employees.assistance_validate = ?",init_date,end_date,true],:include => {:payroll_employee => :payroll_staff},:order => "payroll_staffs.first_name ASC, date ASC")
	end

	#
	# Registro por fecha y empleados activos
	#
	def self.all_by_date_actives_employess(init_date,end_date)
		employess = []
		today = Date.today

		Payroll::Employee.all_actives.each do |employee|
			if employee.assistance_validate
				if employee.income_date < init_date
					start_date = init_date
				else
					start_date = init_date
				end
				start_date  = start_date.split("-").map(&:to_i)
				
				 start_date = Date.new(start_date[0],start_date[1],start_date[2])
				weekdays = AppConfig.weekdays(start_date,today)
				count_weekdays = count(:conditions => ["date IN (?) AND payroll_employees.id = ? AND payroll_employees.assistance_validate = ? ",weekdays.map(&:to_s),employee.id,true],:include => {:payroll_employee => :payroll_staff})
				diff_time_check_in = sum(:diff_time_check_in,:conditions => ["date IN (?) AND payroll_employees.id = ? AND payroll_employees.assistance_validate = ? ",weekdays.map(&:to_s),employee.id,true],:include => {:payroll_employee => :payroll_staff})
				tableless_monitoring_assistance = Payroll::TablelessMonitoringAssistance.new
				#tableless_monitoring_assistance.employee = employee
				tableless_monitoring_assistance.employee_fullname = employee.fullname
				tableless_monitoring_assistance.count_weekdays = count_weekdays
				tableless_monitoring_assistance.count_non_weekdays = weekdays.size - count_weekdays
				tableless_monitoring_assistance.diff_time_check_in = diff_time_check_in
				employess << tableless_monitoring_assistance
			end
		end
		#
		employess
	end

end
