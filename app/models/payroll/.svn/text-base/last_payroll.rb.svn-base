class Payroll::LastPayroll < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	humanize_attributes		:payroll_concept_personal_type => "Concepto",
												:payroll_employee => "Empleado",
												:payroll_payment_frequency => "Frecuencia de pago",
												:unit => "Unidad",
												:amount_allocated => "Asiganción",
												:amount_deducted => "Deducción",
                        :amount_allocations => "TOTAL ASIGNACIONES",
                        :amount_deductions => "TOTAL DEDUCCIONES",
                        :contractual_obligations => "Obligaciones contratuales",
                        :other_deductions => "Otras deducciones",
                        :total_amount => "NETO A PAGAR"

	belongs_to :payroll_concept_personal_type,:class_name => "Payroll::ConceptPersonalType"
	belongs_to :payroll_employee,:class_name => "Payroll::Employee",:foreign_key => "payroll_employee_id"
	belongs_to :payroll_payment_frequency,:class_name => "Payroll::PaymentFrequency"
	belongs_to :payroll_regular_payroll_check,:class_name => "Payroll::RegularPayrollCheck"





	#
	# Empleados pagados
	#
	def self.paid_employees(month,year)
    payroll_regular_payroll_checks = Payroll::RegularPayrollCheck.all(:conditions => ["month = ? AND year = ?",month,year])
		all(:select => :payroll_employee_id,:conditions => ["payroll_regular_payroll_check_id IN (?) ",payroll_regular_payroll_checks.map(&:id)],:group => "payroll_employee_id").map(&:payroll_employee).sort! { |a,b| a.income_date.downcase <=> b.income_date.downcase }
	end


  #
  # Monto por concepto
  #
  def self.amount_by_concept(regular_payroll_check,employee,concept)
    record = first(:conditions => ["payroll_regular_payroll_check_id = ? AND payroll_employee_id = ? AND payroll_concepts.id = ?",regular_payroll_check.id,employee.id,concept.id],:joins => [:payroll_concept_personal_type => [:payroll_concept]])
    record.nil? ? 0 : (record.amount_allocated + record.amount_deducted)
  end
  
  #
  # Monto por concepto
  #
  def self.base_amount_by_concept(regular_payroll_check,employee,concept)
    record = first(:conditions => ["payroll_regular_payroll_check_id = ? AND payroll_employee_id = ? AND payroll_concepts.id = ?",regular_payroll_check.id,employee.id,concept.id],:joins => [:payroll_concept_personal_type => [:payroll_concept]])
    record.nil? ? 0 : (record.amount_base)
  end

	#
	# Busca lsos empleados por nomina
	#
	def self.all_by_employees
		last_payroll_by_employess = []
		employees = Payroll::Employee.all_actives
		employees.each do |employee|
			concepts_last_payroll = employee.payroll_last_payrolls
			last_payroll_by_employess << {:payroll_employee => employee,:concepts_last_payroll => concepts_last_payroll}
		end
		last_payroll_by_employess
	end

	#
	# busca la siguiente nomian a prtir de hoy
	#
	def self.next_payroll
		if Time.now.day <= 15
			"01/#{Time.now.month.to_code("02")}/#{Time.now.year} al 15/#{Time.now.month.to_code("02")}/#{Time.now.year}"
		else
			"16/#{Time.now.month.to_code("02")}/#{Time.now.year} al #{Date.civil(Time.now.year, Time.now.month, -1).day}/#{Time.now.month.to_code("02")}/#{Time.now.year}"
		end
	end

	def self.add_new(payroll_regular_payroll_check,employee,payroll_concept_personal_type,payroll_payment_frequency,unit,amount,base_amount,note)
				is_allocated = payroll_concept_personal_type.payroll_concept.is_allocation
				object = new
				object.payroll_regular_payroll_check = payroll_regular_payroll_check

				object.payroll_employee = employee
				object.payroll_concept_personal_type = payroll_concept_personal_type
				object.payroll_payment_frequency = payroll_payment_frequency
				object.unit = unit
        object.note = note
        
				object.amount_allocated = 0
				object.amount_deducted = 0
				if is_allocated
					object.amount_allocated = amount
				else
					object.amount_deducted = amount
				end
				object.amount_base = base_amount
				success = object.valid?
				if success
					object.save
				else
					puts "***** ERRROR"
				end
				{:success => success,:object => object}
	end


	#
	# Generar proceso masico
	#
	def self.massive_process(regular_payroll_check)
		#all.map(&:delete)
		regular_payroll_check.payroll_last_payrolls.map(&:destroy)
		payment_frequencies = payment_frequencies_by_regular_payroll_check(regular_payroll_check)
		init_day = regular_payroll_check.init_date.split("/").first
		end_day = regular_payroll_check.end_date.split("/").first
		
		regular_payroll_check.payroll_personal_type.active_payroll_employees.all.each do |employee|

		
			# Concepto fijos
			allocations_amount_with_islr = 0
			allocations_amount_with_faov = 0
			allocations_amount_with_sso = 0
			allocations_amount_with_spf = 0
			salary = employee.salary
      
      #Ingresos en postiempo calculo segun fecha de ingreso
      if  employee.join_studs(regular_payroll_check.init_date)
            init_day = employee.income_date.to_default_date.split("/").first
      end

			employee.payroll_fixed_concepts.all(:conditions => ["payroll_payment_frequency_id IN (?)",payment_frequencies]).each do |fixed_concept|
				######################   Fijos   ##########################################
				concept_personal_type = fixed_concept.payroll_concept_personal_type
				concept = concept_personal_type.payroll_concept
				amount = fixed_concept.amount
				unit = fixed_concept.unit
        note = fixed_concept.note
				payroll_payment_frequency = fixed_concept.payroll_payment_frequency
				payroll_concept_personal_type = fixed_concept.payroll_concept_personal_type
				###########################################################################
				
				###BEGIN: Validaciones con respecto a los conceptos
					if concept.is_basic_salary
						days_in_fortnight = employee.days_between_from_income_date_to_now(regular_payroll_check.end_date)
						if days_in_fortnight < AppConfig.payroll_fortnight
							amount = employee.salary_for_day * days_in_fortnight
              unit = days_in_fortnight
						end
					end
          if concept_personal_type.payroll_amount_type.tag_name.eql?(Payroll::AmountType::PORCENTUAL)
            amount = amount*unit*employee.salary/100*payroll_payment_frequency.factor
          end


				###END
				result = add_new(regular_payroll_check,employee,payroll_concept_personal_type,payroll_payment_frequency,unit,amount,salary,note)

				#payroll_concept_personal_type.payroll_concept.is_basic_salary

				if result[:success] and concept.is_allocation
					allocations_amount_with_islr += amount if concept_personal_type.retains_islr
					allocations_amount_with_faov += amount if concept_personal_type.retains_faov
					allocations_amount_with_sso += amount if concept_personal_type.retains_sso
					allocations_amount_with_spf += amount if concept_personal_type.retains_spf
				end
			end

			#Conceptos variables
			#
			#
			employee.payroll_variable_concepts.all(:conditions => ["payroll_payment_frequency_id IN (?)",payment_frequencies]).each do |variable_concept|
				result = add_new(regular_payroll_check,employee,variable_concept.payroll_concept_personal_type,variable_concept.payroll_payment_frequency,variable_concept.unit,variable_concept.amount,salary,variable_concept.note)
				###################### Variables ##########################################
				concept = variable_concept.payroll_concept_personal_type.payroll_concept
				concept_personal_type = variable_concept.payroll_concept_personal_type
				amount = variable_concept.amount
				###########################################################################
				if result[:success] and concept.is_allocation
					allocations_amount_with_islr += amount if concept_personal_type.retains_islr
					allocations_amount_with_faov += amount if concept_personal_type.retains_faov
					allocations_amount_with_sso += amount if concept_personal_type.retains_sso
					allocations_amount_with_spf += amount if concept_personal_type.retains_spf
				end

        if result[:success] and !concept.is_allocation
					allocations_amount_with_islr -= amount if concept_personal_type.retains_islr
					allocations_amount_with_faov -= amount if concept_personal_type.retains_faov
					allocations_amount_with_sso -= amount if concept_personal_type.retains_sso
					allocations_amount_with_spf -= amount if concept_personal_type.retains_spf
				end

			end


			#Deducciones de ley
			if employee.faov_listed
				concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::FAOV,employee.payroll_personal_type)
				add_new(regular_payroll_check,employee,concept_personal_type,concept_personal_type.payroll_payment_frequency,0,employee.faov_calculate(allocations_amount_with_faov),allocations_amount_with_faov,"")
			end
			if employee.sso_listed
				concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::SSO,employee.payroll_personal_type)
				add_new(regular_payroll_check,employee,concept_personal_type,concept_personal_type.payroll_payment_frequency,0,employee.sso_calculate(salary,{:init_day => init_day,:end_day => end_day}),salary,"")
			end
			if employee.spf_listed
				concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::SPF,employee.payroll_personal_type)
				add_new(regular_payroll_check,employee,concept_personal_type,concept_personal_type.payroll_payment_frequency,0,employee.spf_calculate(salary,{:init_day => init_day,:end_day => end_day}),salary,"")
			end
			if employee.islr_listed?
        
        
				concept_personal_type = Payroll::ConceptPersonalType.find_by_code_concept(Payroll::Concept::ISLR,employee.payroll_personal_type)
				add_new(regular_payroll_check,employee,concept_personal_type,concept_personal_type.payroll_payment_frequency,0,employee.islr_calculate(allocations_amount_with_islr),allocations_amount_with_islr,"")
			end
		end
	end

	#
	# Deterina las frecucias de pago a canclar en periodo actual
	#
	def self.payment_frequencies_by_regular_payroll_check(regular_payroll_check)
		payment_frequencies = []
		payment_frequencies << Payroll::PaymentFrequency.first(:conditions => {:tag_name => Payroll::PaymentFrequency::AMBAS_QUINCENAS}).id
		case regular_payroll_check.fortnight
			 when 1
				 payment_frequencies << Payroll::PaymentFrequency.first(:conditions => {:tag_name => Payroll::PaymentFrequency::PRIMERA_QUINCENA}).id
				when 2
					payment_frequencies << Payroll::PaymentFrequency.first(:conditions => {:tag_name => Payroll::PaymentFrequency::SEGUNDA_QUINCENA}).id
		end
	end


end