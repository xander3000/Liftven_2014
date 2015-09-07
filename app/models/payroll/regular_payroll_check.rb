class Payroll::RegularPayrollCheck < ActiveRecord::Base
	def self.table_name_prefix
    'payroll_'
  end

	attr_accessor :paid_employees,:paid_total

	humanize_attributes :payroll_personal_type => "Tipo Personal",
											:init_date => "Feha inicio",
											:end_date => "Fecha fin",
											:fortnight => "Quincena",
											:process_date => "Fecha proceso",
											:user => "Usuario",
											:paid => "¿Pagada?",
											:test => "Modo prueba",
											:id => "Nomina",
											:year => "Año",
											:month => "Mes",
											:paid_employees => "abonados",
											:paid_total => "Total pagado"

	has_many :payroll_last_payrolls,:class_name => "Payroll::LastPayroll",:foreign_key => "payroll_regular_payroll_check_id"
	belongs_to :payroll_personal_type,:class_name => "Payroll::PersonalType"
	belongs_to :user
	belongs_to :paid_by,:class_name => "User"

	validates_presence_of :payroll_personal_type,:init_date,:end_date,:fortnight,:process_date,:user#,:year,:month
	before_save		:set_default_values


	named_scope :all_paid, lambda { |tag_name|  { :conditions => {:paid => true}  }}


  #
  # Nombre
  #
  def name
    "#{month.to_code('2')}/#{year} (#{fortnight}º Quincena)"
  end

	#
	# Total pagado
	#
	def paid_total
		allocations = payroll_last_payrolls.sum("amount_allocated")
		deductions = payroll_last_payrolls.sum("amount_deducted")
		allocations - deductions
	end

	#
	# Empleados pagados
	#
	def paid_employees
		payroll_last_payrolls.all(:select => :payroll_employee_id,:group => "payroll_employee_id").map(&:payroll_employee).sort! { |a,b| a.income_date.downcase <=> b.income_date.downcase }
	end

  #
  # Conceptos nomina 
  #
  def concepts_by_last_payrolls
    allocations = payroll_last_payrolls.all(:conditions => ["payroll_concepts.tag_name NOT IN (?) AND is_allocation = ?",Payroll::Concept.all_basic,true],:joins => [:payroll_concept_personal_type => :payroll_concept]).map(&:payroll_concept_personal_type).uniq
    deductions = payroll_last_payrolls.all(:conditions => ["payroll_concepts.tag_name NOT IN (?) AND is_allocation = ?",Payroll::Concept.all_basic,false],:joins => [:payroll_concept_personal_type => :payroll_concept]).map(&:payroll_concept_personal_type).uniq
    {:allocations => allocations,:deductions => deductions}
  end

	#
	# Todos las nomina procedas por periodo
	#
	def self.all_group_by_period
		all(:select => "year, month,payroll_personal_type_id",:conditions => {:paid => true},:group => "year, month,payroll_personal_type_id")
	end

	#
	# busca la siguiente nomian a prtir de hoy
	#
	def self.next_payroll(payroll_personal_type,to_string=false)
		time_next_payroll,init_date,end_date,fortnight = date_next_payroll

		result = {:payroll_personal_type_id => payroll_personal_type.id,:init_date => init_date, :end_date => end_date,:fortnight => fortnight}

		next_payroll_by_personal_type = first(:conditions => result,:order => "id DESC")
		if next_payroll_by_personal_type and !next_payroll_by_personal_type[:test]
			paid = true
		else
			paid = false
		end
		result[:paid] = paid
		result[:process_date] = Time.now.strftime("%d/%m/%Y")
		
		result
	end

	#
	# Obtiene le periodp de la siguiente nomina
	#
	def self.date_next_payroll
		time_next_payroll = Time.now

		if time_next_payroll.day <= 15
			init_date = "01/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			end_date = "15/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			fortnight = 1
		else
			init_date = "16/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			end_date = "#{Date.civil(Time.now.year, Time.now.month, -1).day}/#{Time.now.month.to_code("02")}/#{Time.now.year}"
			fortnight = 2
		end
		return time_next_payroll,init_date,end_date,fortnight
	end

  	#
	# Obtiene le periodp de la siguiente nomina
	#
	def date_payroll
		return created_at,init_date,end_date,fortnight
	end

	#
	# Si existe
	#
	def exist?
		self.class.first(:conditions => {:init_date => init_date, :end_date => end_date,:fortnight => fortnight,:payroll_personal_type_id => payroll_personal_type_id})
	end

	#
	# Pagar definitivo
	#
	def definitely_pay(paid_by)
		update_attributes(:test => false,:paid => true,:paid_by_id => paid_by.id)
		payroll_last_payrolls.each do |last_payroll|
			attributes_c = last_payroll.attributes
			attributes_c.delete("id")
			attributes_c.delete("created_at")
			attributes_c.delete("updated_at")
			attributes_c["year"] = Time.now.year
			attributes_c["month"] = Time.now.month.to_code("02")
			historical_payroll = Payroll::HistoricalPayroll.new(attributes_c)
			if historical_payroll.valid?
				historical_payroll.save
			end
		end
		payment_frequencies = Payroll::LastPayroll.payment_frequencies_by_regular_payroll_check(self)
		payroll_personal_type.active_payroll_employees.all.each do |employee|
			employee.payroll_variable_concepts.all(:conditions => ["payroll_payment_frequency_id IN (?)",payment_frequencies]).each do |variable_concept|
				variable_concept.destroy
			end
		end
	end

	#
	# Envia al empleado su recibo de pago asociado al objeto
	#
	def send_payment_receipt_by_mail(employee,file_path)
			begin
        logger.info "---BEGIN: send mail send_payment_receipt_by_mail---"
        Mailer::deliver_send_payment_receipt(self,employee,file_path)
        logger.info "---END: mail send successfull---"
      rescue Exception => e
          logger.error "---END: Error---"
		   		logger.error e
          logger.error "------"
      end
	end

	#
	# Monto base por conceptp y empleado
	#
	def base_amount_by_concept_and_employee(concept_code,employee)
		payroll_last_payrolls.first(:conditions => ["payroll_concepts.tag_name = ? AND payroll_last_payrolls.payroll_employee_id = ?",concept_code,employee.id],:include => {:payroll_concept_personal_type => :payroll_concept})
	end

	#
	# Setea los valores por defecto
	#
	def set_default_values
		self.month = init_date.split("/")[1]
		self.year = init_date.split("/")[2]
		if !self.test
			self.paid = true
		end
	end


	#
	# es segunda nomina
	#
	def is_second_fortnight?
		fortnight.eql?(2)
	end

	#
	# Ejecutar proceso de envio de correos de recibos en segundo plano
	#
	def send_background_masive_payment_receipt_by_mail(file_prefix,file_path)
		system("nohup ruby script/runner \"Payroll::RegularPayrollCheck.send_masive_payment_receipt_by_mail(#{id},'#{file_prefix}','#{file_path}')\" &")
		#self.class.send_masive_payment_receipt_by_mail(id,file_prefix,file_path)
	end



	#
	# Enviar recibos por correo a cada trabajador
	#
		def self.send_masive_payment_receipt_by_mail(id,file_prefix,file_path)
			object = self.find(id)
			object.payroll_personal_type.active_payroll_employees.all.each do |employee|
				file_name = "#{file_prefix}_#{employee.id}"
				save_path = "#{file_path}/#{file_name}.pdf"
				object.send_payment_receipt_by_mail(employee,save_path)
			end
	end

	#
	# Busqueda de resumen de nomina
	#
	def self.find_resumen_concept_personal_type(options={})
		options[:fortnight] = options[:fortnight] || ""
    options[:payroll_concept_personal_type_id] = options[:payroll_concept_personal_type_id] || ""
		options[:payroll_personal_type_id] = options[:payroll_personal_type_id] || ""
		
		clausules = []
		values = []
		conditions  = []
		clausules_int = []
		values_int = []
		conditions_int  = []
		regular_payroll_checks = {}

		if !options[:payroll_personal_type_id].empty?
			clausules << "payroll_personal_type_id = ?"
			values << "#{options[:payroll_personal_type_id]}"
		end
		if !options[:year].empty?
			clausules << "year = ?"
			values << "#{options[:year]}"
		end
		if !options[:month].empty?
			clausules << "month = ?"
			values << "#{options[:month]}"
		end
		if !options[:fortnight].empty?
			clausules << "fortnight = ?"
			values << "#{options[:fortnight]}"
		end
		if !options[:payroll_concept_personal_type_id].empty?
			clausules_int << "payroll_concept_personal_type_id = ?"
			values_int << "#{options[:payroll_concept_personal_type_id]}"
		end

		conditions << clausules.join(" AND ")
		conditions.concat( values )

		conditions_int << clausules_int.join(" AND ")
		conditions_int.concat( values_int )

		Payroll::RegularPayrollCheck.all(:conditions => conditions).each do |regular_payroll_check|
			aux = {}
			regular_payroll_checks["payroll_personal_type_#{regular_payroll_check.payroll_personal_type_id}".to_sym] = {} if regular_payroll_checks["payroll_personal_type_#{regular_payroll_check.payroll_personal_type_id}".to_sym].nil?
			regular_payroll_checks["payroll_personal_type_#{regular_payroll_check.payroll_personal_type_id}".to_sym][:fortnights] = [] if regular_payroll_checks["payroll_personal_type_#{regular_payroll_check.payroll_personal_type_id}".to_sym][:fortnights].nil?

			payroll_last_payrolls = regular_payroll_check.payroll_last_payrolls.all(:conditions => conditions_int)

			payroll_concepts = {}

			payroll_last_payrolls.each do |payroll_last_payroll|
				payroll_concepts[payroll_last_payroll.payroll_concept_personal_type_id.to_s.to_sym] = {:name => payroll_last_payroll.payroll_concept_personal_type.payroll_concept.name,:amount => 0} if payroll_concepts[payroll_last_payroll.payroll_concept_personal_type_id.to_s.to_sym].nil?
				amount = payroll_concepts[payroll_last_payroll.payroll_concept_personal_type_id.to_s.to_sym][:amount] + payroll_last_payroll.amount_allocated + payroll_last_payroll.amount_deducted
				payroll_concepts[payroll_last_payroll.payroll_concept_personal_type_id.to_s.to_sym][:amount] = amount
			end
			aux[:regular_payroll_check] = regular_payroll_check
			aux[:payroll_concepts] = payroll_concepts

			regular_payroll_checks["payroll_personal_type_#{regular_payroll_check.payroll_personal_type_id}".to_sym][:fortnights] << aux
			regular_payroll_checks["payroll_personal_type_#{regular_payroll_check.payroll_personal_type_id}".to_sym][:payroll_personal_type] = regular_payroll_check.payroll_personal_type.name
		end
		regular_payroll_checks
	end


end
