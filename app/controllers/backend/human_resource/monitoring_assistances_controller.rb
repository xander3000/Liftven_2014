class Backend::HumanResource::MonitoringAssistancesController < Backend::HumanResource::BaseController
	filter_parameter_logging :access_code
   skip_before_filter :validate_autorizations,:only => [:new_external,:search_employee,:new_external_form,:process_external,:default_listing,:select_date]
  skip_before_filter :validate_session,:only => [:new_external,:search_employee,:new_external_form,:process_external,:default_listing,:select_date]
    
	def index
		default_listing
		 respond_to do |format|
				format.html
				format.xls {send_data @monitoring_assistances_all_active_employeess.to_xls(:header => false,:except => [:employee], :headers => ["Inasistencias (días)","Asistencias (días)","Retraso (min)","Empleado" ]), :type => "application/vnd.ms-excel; charset=utf-8; header=present",:filename => "Asistencia_Mes.xls" }
    end

	end

  def select_date
    default_listing
  end

	def new
		@title = "Control de asistencia / Nuevo registro"
		@monitoring_assistance = Payroll::MonitoringAssistance.new
	end

	def create
		@monitoring_assistance = Payroll::MonitoringAssistance.new(params[:payroll_monitoring_assistance])
		@success = @monitoring_assistance.valid?
		if @success
			@monitoring_assistance.save
		end
	end

	def show
		@title = "Control de asistencia / Detalle del registro"
		@monitoring_assistance = Payroll::MonitoringAssistance.find(params[:id])
	end

	def search_employee
		@employees = [Payroll::Employee.first_by_identification_document(params[:payroll_monitoring_assistance][:employee_document_identificacion])].compact
		if @employees.empty?
			flash[:error] = "Empleado con cédula #{params[:payroll_monitoring_assistance][:employee_document_identificacion]} no encontrado"
			@employees = Payroll::Employee.all
		end
		@monitoring_assistance = Payroll::MonitoringAssistance.new
    default
		render :layout =>  "backend/external_monitoring_assistance",:action => "new_external"
	end

	def new_external
		@monitoring_assistance = Payroll::MonitoringAssistance.new
		@employees = Payroll::Employee.all_actives#_without_assistance_today
		default
		render :layout =>  "backend/external_monitoring_assistance"
	end

	def new_external_form
		@employee = Payroll::Employee.find_by_id(params[:employee_id])
		@payroll_monitoring_assistance_today = @employee.payroll_monitoring_assistance_today
	end

	def process_external
		@employee = Payroll::Employee.find_by_id(params[:employee_id])
		type_access_code = params[:type_access_code]
		@success = (@employee and @employee.valid_access_code?(params[:access_code]))
		if @success
			@employee.register_assistance_check_in_today(type_access_code)
			flash[:error] = nil
			case type_access_code.to_i
				when 1 
					flash[:notice] = "Acceso correcto<br/>Bienvenido #{@employee.fullname}!"
			when 2
					flash[:notice] = "Acceso correcto<br/>Buen provecho #{@employee.fullname}!"
			when 3
					flash[:notice] = "Acceso correcto<br/>Despues de una comelona, nada mejor que volver a trabajar #{@employee.fullname}!"
			when 4
					flash[:notice] = "Acceso correcto<br/>Hasta luego #{@employee.fullname}!"
			end
		else
			flash[:notice] = nil
			flash[:error] = "Acceso incorrecto<br/>Intentelo de nuevo!"
		end
		
	end

	def default_listing
			@title = "Control de asistencia"
			if params[:regular_paroll_check]
				@time_next_payroll,@init_date,@end_date,@fortnight = Payroll::RegularPayrollCheck.find(params[:regular_paroll_check][:id]).date_payroll
			else
				@time_next_payroll,@init_date,@end_date,@fortnight = Payroll::RegularPayrollCheck.date_next_payroll
			end
      
      init_date = @init_date.split("/")
      init_date = "#{init_date[2]}-#{init_date[1]}-#{init_date[0]}"
      end_date = @end_date.split("/")
      end_date = "#{end_date[2]}-#{end_date[1]}-#{end_date[0]}"
      @monitoring_assistances = Payroll::MonitoringAssistance.all_by_date(init_date, end_date)
			@monitoring_assistances_all_active_employeess = Payroll::MonitoringAssistance.all_by_date_actives_employess(init_date, end_date)
      @regular_paroll_checks = Payroll::RegularPayrollCheck.all
	end

	def default
		hours,minutes,seconds = AppConfig.start_workday.split(":").map(&:to_i)
		start_time = DateTime.now
		end_time = DateTime.new(start_time.year,start_time.month, start_time.day,hours,minutes,seconds,start_time.offset)
		@hours,@minutes,@seconds,@frac = Date.day_fraction_to_time(end_time-start_time)
		if @hours.to_i < 0
			@startTime = '00:00:00'
		else
			@startTime = "#{@hours.to_code("02")}:#{@minutes.to_code("02")}:#{@seconds.to_code("02")}"
		end
	end

end
