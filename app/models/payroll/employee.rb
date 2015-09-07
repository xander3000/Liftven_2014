class Payroll::Employee < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	DEFAULT_ACCESS_CODE = "teamwork"

	humanize_attributes		:payroll_department => "Departamento",
												:payroll_personal_type => "Tipo personal",
												:payroll_position => "Cargo",
												:payroll_staff => "Personal",
												:salary => "Sueldo básico",
                        :payroll_employee_status_type => "Estatus",
												:salary_fortnight => "Salario quincenal",
                        :salary_daily => "Salario diario",
												:integral_salary => "Sueldo basico",
												:income_date => "Fecha de ingreso",
												:discharge_date => "Fecha de egreso",
												:islr_percentage => "% I.S.L.R.",
												:faov_listed => "¿cotiza FAOV?",
												:sso_listed => "¿cotiza SSO?",
												:spf_listed => "¿cotiza SPF?",
												:fju_listed => "¿cotiza FJU?",
                        :payroll_payment_method_type => "Forma de pago",
                        :account_number => "Número de cuenta",
												:name => "Nombre",
                        :fullname => "Nombre y Apellido",
												:access_code => "Código acceso",
												:assistance_validate => "¿Validar asistencia?"


	belongs_to :payroll_staff,:class_name => "Payroll::Staff",:foreign_key => "payroll_staff_id"
	belongs_to :payroll_position,:class_name => "Payroll::Position"
	belongs_to :payroll_personal_type,:class_name => "Payroll::PersonalType"
	belongs_to :payroll_department,:class_name => "Payroll::Department"
	belongs_to :payroll_employee_status_type,:class_name => "Payroll::EmployeeStatusType"
	belongs_to :payroll_payment_method_type,:class_name => "Payroll::PaymentMethodType"
  belongs_to :historical_wage_adjustment,:class_name => "Payroll::HistoricalWageAdjustment"
  has_one		 :payroll_monitoring_assistance_today,:class_name => "Payroll::MonitoringAssistance",:foreign_key => "payroll_employee_id", :conditions => {:date => Time.now.to_date}
	has_many :payroll_fixed_concepts,:class_name => "Payroll::FixedConcept",:foreign_key => "payroll_employee_id"
	has_many :payroll_variable_concepts,:class_name => "Payroll::VariableConcept",:foreign_key => "payroll_employee_id"
	has_many :payroll_last_payrolls,:class_name => "Payroll::LastPayroll",:foreign_key => "payroll_employee_id"
	has_many :payroll_historical_payrolls,:class_name => "Payroll::HistoricalPayroll",:foreign_key => "payroll_employee_id"
	has_many :payroll_monitoring_assistances,:class_name => "Payroll::MonitoringAssistance",:foreign_key => "payroll_employee_id"

	validates_presence_of :payroll_personal_type,:payroll_position,:salary,:income_date,:payroll_department,:payroll_payment_method_type
	validates_presence_of :access_code,:if => Proc.new { |employee| employee.assistance_validate }
  after_create :associate_fixed_concepts
	before_create :encrypt_access_code
	validates_presence_of :discharge_date,:if => Proc.new { |employee| employee.payroll_employee_status_type and employee.payroll_employee_status_type.is_graduate? }

  #
  # Retorna la informacion de contacto del cliente
  #
  def name
    payroll_staff.fullname
  end

  #
  # Retorna la informacion de contacto del cliente
  #
  def fullname
    payroll_staff.fullname
  end

	#
  # Retorna la informacion de contacto del cliente
  #
  def identification_document
    payroll_staff.identification_document
  end

	#
  # Retorna la informacion de contacto del cliente
  #
  def only_identification_document
		payroll_staff.identification_document.split("-").last
  end


	#
  # Retorna la informacion de contacto del cliente
  #
  def nationality
    payroll_staff.identification_document.first
  end


	#
  # Retorna la informacion de ubicacion o dependecia
  #
  def location
    "Planta"
  end

  #
  # Retorna la informacion de contacto del cliente
  #
  def contact
    contact_category.contact
  end

  #
  # Retorna el usuario asociado a este empelado
  #
  def user
    contact.user
  end


  #
  # Retorna las ordenes del empleado
  #

  def orders
    return [] if user.nil?
		Order.by_user_for_selection(user)
  end

	#
	# Es validoel codigo de acceso
	#
	def valid_access_code?(code)
		Digest::MD5.hexdigest(code).eql?(access_code)
	end

	#
	#
	#
	def encrypt_access_code
		self.access_code = Digest::MD5.hexdigest(self.access_code)
	end

	#
	# Registra asistencia del dia
	#
	def register_assistance_check_in_today(type_access_code)
		monitoring_assistance = payroll_monitoring_assistance_today || Payroll::MonitoringAssistance.new
		
		monitoring_assistance.payroll_employee = self
		monitoring_assistance.date = Time.now.to_date

		case type_access_code.to_i
			when 1
				monitoring_assistance.time_check_in = Time.now.time
			when 2
				monitoring_assistance.time_lunch_in = Time.now.time
			when 3
				monitoring_assistance.time_lunch_out = Time.now.time
			when 4
			monitoring_assistance.time_check_out = Time.now.time
		end
		
		monitoring_assistance.save
	end

	#
	# Nuemro de dias laborados dese ingreso
	#
	def days_between_from_income_date_to_now(date_now)
		to = date_now.split("/")
    if to[0].to_i.eql?(31)
        day_to = 30
    else
        day_to = to[0].to_i
    end
		from  = income_date.to_default_date.split("/")
		Date.parse("#{to[1]}/#{day_to}/#{to[2]}").mjd - Date.parse("#{from[1].to_i}/#{from[0]}/#{from[2]}").mjd + 1
	end

  #
	# Determina si el ingreso es a post tiempo
	#
	def join_studs(date_now)
		days_between_from_income_date_to_now(date_now) < 0
	end
  
  
	#
	# Salario diario
	#
	def salary_for_day
		salary / AppConfig.payroll_days
	end

	#
	# Todos ls activos
	#
	def self.all_actives
		all(:conditions => ["payroll_employee_status_types.tag_name = ?",Payroll::EmployeeStatusType::ACTIVE],:include => [:payroll_employee_status_type,:payroll_staff],:order => "payroll_employees.income_date ASC")
	end

	#
  # Retorna la informacion de ubicacion o dependecia
  #
  def self.first_by_identification_document(identification_document)
		employees_with_assistance_today = Payroll::MonitoringAssistance.all(:select => :payroll_employee_id,:conditions => {:date => Time.now.to_date}).map(&:payroll_employee_id)
		employees_with_assistance_today << 0
    first(:conditions => ["payroll_employee_status_types.tag_name = ? AND payroll_staffs.identification_document LIKE ? AND  payroll_employees.id NOT IN (?)",Payroll::EmployeeStatusType::ACTIVE,"%#{identification_document}%",employees_with_assistance_today],:include => [:payroll_staff,:payroll_employee_status_type])
  end


	#
	# Reset codigo acceso al default
	#
	def self.reset_access_code
		all.each do |employee|
			employee.update_attributes(:access_code => Digest::MD5.hexdigest(employee.only_identification_document.to_i.to_s))
		end
	end

	#
	# Todos de acuerdo al estatus
	#
	def self.all_by_status(status)
		all(:conditions => ["payroll_employee_status_types.tag_name = ?",status],:include => [:payroll_employee_status_type,:payroll_staff],:order => "payroll_employees.income_date ASC")
	end

	#
	# Todos sin asitencia por registrar
	#
	def self.all_without_assistance_today
		employees_with_assistance_today = Payroll::MonitoringAssistance.all(:select => :payroll_employee_id,:conditions => {:date => Time.now.to_date}).map(&:payroll_employee_id)
		employees_with_assistance_today << 0
		all(:conditions => ["payroll_employee_status_types.tag_name = ? AND payroll_employees.id NOT IN (?)",Payroll::EmployeeStatusType::ACTIVE,employees_with_assistance_today],:include => [:payroll_employee_status_type])
	end

	#
	# Empleados por tipo de personal
	#
	def self.all_by_personal_type(options={})
		options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "employees.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "employees.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


    personal_types = Payroll::PersonalType.all

    employees_by_personal_type = []
    joins = [:contact_category => [:contact],:payroll_personal_type => []]

    personal_types.each do |personal_type|
      clausules = []
      values = []
      conditions  = []
      clausules << "employees.status = ?"
      values << "A"
      clausules << "payroll_personal_types.id = ?"
      values << personal_type.id


      conditions << clausules.join(" AND ")
      conditions.concat( values )
      employees = all(:conditions => conditions,:joins => joins,:group => "employees.id")
      employees_paginate = employees.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      employees_by_personal_type << {:personal_type => personal_type,:count => employees.size,:paginate => employees_paginate}
    end
    employees_by_personal_type
	end


	#
	# Quincena
	#
	def salary_fortnight
		salary/2
	end

  #
  #
  #
	def payroll_by_regular_payroll_check(payroll_regular_payroll_check)
    payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => {:payroll_employee_id => id})
	end

  #
  # Totales
  #
	def totals_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
    amount_allocated = 0
    amount_deducted = 0
		payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => {:payroll_employee_id => id}).each do |last_payroll|
      amount_allocated +=last_payroll.amount_allocated
      amount_deducted +=last_payroll.amount_deducted
    end
    {:total_amount => (amount_allocated-amount_deducted),:amount_deductions => amount_deducted,:amount_allocations => amount_allocated}
	end

  #
  # Totales de obligaciones contratuales
  #
	def contractual_obligations_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
    contractual_obligations = {:total => 0}
		payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => ["payroll_employee_id = ? AND payroll_concepts.tag_name IN (?)",  id,Payroll::Concept.all_deductions],:include => [:payroll_concept_personal_type => :payroll_concept]).each do |last_payroll|
      contractual_obligations[last_payroll.payroll_concept_personal_type.payroll_concept.tag_name.to_sym] = last_payroll.amount_deducted
      contractual_obligations[:total] += last_payroll.amount_deducted
    end
    contractual_obligations
	end

  #
  # Totales de obligaciones contratuales
  #
	def concepts_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
    contractual_obligations = {:total => 0}
    p "----------------------"
		payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => ["payroll_employee_id = ?",  id],:include => [:payroll_concept_personal_type => :payroll_concept]).each do |last_payroll|
      contractual_obligations[last_payroll.payroll_concept_personal_type.payroll_concept.tag_name.to_sym] = last_payroll.amount_allocated - last_payroll.amount_deducted
      contractual_obligations[:total] += last_payroll.amount_deducted
    end
    p contractual_obligations
    contractual_obligations
	end


	#
	# Calculo seguro social
	#
	def sso_calculate(allocations_amount,options={})
		month = options[:month] || Date.today.month
		year = options[:year] || Date.today.year
		init_day = options[:init_day]
		end_day = options[:end_day]
    concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::SSO,payroll_personal_type)
		percentage = concept_personal_type.value
    (allocations_amount*12/AppConfig.weeks_in_year*percentage/100*AppConfig.mondays_in_month(init_day,end_day,month,year)).round(2)#*concept_personal_type.payroll_payment_frequency.factor.round(2)
	end

	#
	# Calculo FJU
	#
	def fju_calculate

	end


	#
	#Calculo SPF
	#
	def spf_calculate(allocations_amount,options={})
		month = options[:month] || Date.today.month
		year = options[:year] || Date.today.year
		init_day = options[:init_day]
		end_day = options[:end_day]
    concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::SPF,payroll_personal_type)
		percentage = concept_personal_type.value
		(allocations_amount*12/AppConfig.weeks_in_year*percentage/100*AppConfig.mondays_in_month(init_day,end_day,month,year)).round(2)#*concept_personal_type.payroll_payment_frequency.factor.round(2)
	end


	#
	#
	#
	def islr_listed?
		islr_percentage > 0
	end

	#
	#Calculo ISLR
	#
	def islr_calculate(allocations_amount)
    concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::ISLR,payroll_personal_type)
		(allocations_amount*islr_percentage/100).round(2)
	end

	#
	#Calculo FAOV
	#
	def faov_calculate(allocations_amount)
    concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::FAOV,payroll_personal_type)
		percentage = concept_personal_type.value.round(2)
		(allocations_amount*percentage/100).round(2)
	end


	#
	# Conceptos fijos Asigandos
	#
	def payroll_fixed_allocation_concepts
		payroll_fixed_concepts.all(:conditions => ["payroll_concepts.is_allocation = ?",true],:joins => [:payroll_concept_personal_type => [:payroll_concept]])
	end

	#
	# Conceptos fijos Deducibles
	#
	def payroll_fixed_not_allocation_concepts
		payroll_fixed_concepts.all(:conditions => ["payroll_concepts.is_allocation = ?",false],:joins => [:payroll_concept_personal_type => [:payroll_concept]])
	end

	#
	# Activo?
	#
	def is_active?
		payroll_employee_status_type.tag_name.eql?(Payroll::EmployeeStatusType::ACTIVE)
	end



	#
	# Egresado?
	#
	def is_graduate?
		payroll_employee_status_type.tag_name.eql?(Payroll::EmployeeStatusType::GRADUATE)
	end

	#
	#Asociar conceptos fijos
	#
	def associate_fixed_concepts
		#### Sueldo Basico ####
    
		fixed_concept_salary = Payroll::FixedConcept.new
		basic_salary_payroll_personal_type = Payroll::ConceptPersonalType.basic_salary_payroll_personal_type(payroll_personal_type)
		if basic_salary_payroll_personal_type and !has_fixed_concept_salary?
			fixed_concept_salary.payroll_concept_personal_type =  basic_salary_payroll_personal_type
			fixed_concept_salary.payroll_employee = self
			fixed_concept_salary.amount = salary*basic_salary_payroll_personal_type.payroll_payment_frequency.factor
			fixed_concept_salary.unit = 15
			fixed_concept_salary.payroll_payment_frequency = basic_salary_payroll_personal_type.payroll_payment_frequency
			fixed_concept_salary.save
		end
	end

  #
  # Actualizar el los concpeto por tipo de Persoal actual
  #
  def update_payroll_personal_type_to_fixed_concept
    
    payroll_fixed_concepts.each do |payroll_fixed_concept|
      current_concept_personal_type = payroll_fixed_concept.payroll_concept_personal_type
      new_concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(current_concept_personal_type.payroll_concept.tag_name,payroll_personal_type)
      payroll_fixed_concept.update_attribute(:payroll_concept_personal_type_id,new_concept_personal_type.id)
    end
  end

  #
  # Actalizar el monto de concepto fijo
  #
  def update_value_salary_to_fixed_concept
    if has_fixed_concept_salary?
      basic_salary_payroll_personal_type = Payroll::ConceptPersonalType.basic_salary_payroll_personal_type(payroll_personal_type)
      fixed_concept_salary.update_attributes(:amount => salary*basic_salary_payroll_personal_type.payroll_payment_frequency.factor)
    end
  end

	#
	#Tine concepto de sueldo asignado
	#
	def has_fixed_concept_salary?
		basic_salary_payroll_personal_type = Payroll::ConceptPersonalType.basic_salary_payroll_personal_type(payroll_personal_type)
		!payroll_fixed_concepts(:conditions => {:payroll_concept_personal_type_id => basic_salary_payroll_personal_type.id}).empty?
	end

  #
	#Xoncepto de sueldo asignado
	#
	def fixed_concept_salary
		basic_salary_payroll_personal_type = Payroll::ConceptPersonalType.basic_salary_payroll_personal_type(payroll_personal_type)
		payroll_fixed_concepts.first(:conditions => {:payroll_concept_personal_type_id => basic_salary_payroll_personal_type.id})
	end

	#
	# Todas las pagos del mes
	#
	def all_payroll_payables_by_month_year(month,year)
		payroll_historical_payrolls.all(:conditions => ["payroll_regular_payroll_checks.year = ? AND payroll_regular_payroll_checks.month = ?",year.to_i,month.to_i],:include => [:payroll_regular_payroll_check]).map(&:payroll_regular_payroll_check).uniq
	end

  #
  #
  #
	def amount_total_payroll_by_regular_payroll_check(payroll_regular_payroll_check)
    amount_allocated = 0
    amount_deducted = 0
    payroll_regular_payroll_check.payroll_last_payrolls.all(:conditions => {:payroll_employee_id => id}).each do |last_payroll|
        amount_allocated +=last_payroll.amount_allocated
        amount_deducted +=last_payroll.amount_deducted
    end
    amount_allocated-amount_deducted
	end

	#
  #Busca de acuerdo al parametro <b>attr</b>, cempleado con el valor <b>value<b/>
  #
  def self.find_by_employee_autocomplete(attr,value)
    rows = []
    employees = all(:conditions => ["lower(#{attr}) LIKE lower(?) AND payroll_employee_status_types.tag_name = ?","%#{value}%",Payroll::EmployeeStatusType::ACTIVE],:include => [:payroll_staff,:payroll_employee_status_type],:limit => 10)
    employees.each do |employee|
      rows << {
                "value" => employee.fullname,
                "label" => employee.fullname,
                "id" => employee[:id],
                "fullname" => employee.fullname,
                "identification_document" => employee.identification_document,
                "code_response" => "ok"
              }
    end
    if employees.empty?
      rows = [{
          "value" => value,
          "label" => "Empleado no Registrado",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
  end

end
