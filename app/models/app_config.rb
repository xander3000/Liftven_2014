class AppConfig < ActiveRecord::Base
  CASES_BY_TECHNICIANS =  "CASES_BY_TECHNICIANS"
  TIME_ORDER_WARNING = "TIME_ORDER_WARNING"
  TIME_ORDER_EXPIRED = "TIME_ORDER_EXPIRED"
  TIME_ORDER_UNEXPIRED = "TIME_ORDER_UNEXPIRED"
  WIDTH_QUARTER_SHEET = "WIDTH_QUARTER_SHEET"
  HEIGHT_QUARTER_SHEET = "HEIGHT_QUARTER_SHEET"
  MARGIN_CUT_HEIGHT_QUARTER_SHEET = "MARGIN_CUT_HEIGHT_QUARTER_SHEET"
  MARGIN_CUT_WIDTH_QUARTER_SHEET = "MARGIN_CUT_WIDTH_QUARTER_SHEET"
  TAX = "TAX"
  MIN_QUARTER_SHEET = "MIN_QUARTER_SHEET"
	MAX_QUARTER_SHEET = "MAX_QUARTER_SHEET"
  MIN_PERCENTAGE_ADVANCE_PAYMENT = "MIN_PERCENTAGE_ADVANCE_PAYMENT"
	CURRENCY = "CURRENCY"
	EXPIRY_BUDGET = "EXPIRY_BUDGET"
	START_WORKDAY = "START_WORKDAY"
	FAOV_ACCOUNT = "FAOV_ACCOUNT"
	PAYROLL_DAYS = "PAYROLL_DAYS"
	PAYROLL_FORTNIGHT = "PAYROLL_FORTNIGHT"
	DEFAULT_ACTIONS_CONTROLLER = "DEFAULT_ACTIONS_CONTROLLER"
	ACCOUNTANT_ACCOUNT_LEVEL = "ACCOUNTANT_ACCOUNT_LEVEL"
	BODY_MESSAGE_PAYMENT_RECEIPT = "BODY_MESSAGE_PAYMENT_RECEIPT"

	validates_uniqueness_of :name


  #
  # Busca el valor de un parametro de configuracion
  #
  def self.get_value_by_name(name)
    find_by_name(name).value
  end


  #
  # Tiempo actual de NO VENCIDO de una orden
  #
  def self.current_orden_unexpired_date
    Time.now - get_value_by_name(TIME_ORDER_UNEXPIRED).to_i.days
  end

  #
  # Tiempo actual de  VENCIDO de una orden
  #
  def self.current_orden_expired_date
    Time.now - get_value_by_name(TIME_ORDER_EXPIRED).to_i.days
  end

  #
  # Tiempo actual de POR VENCER de una orden
  #
  def self.current_orden_warning_date
    Time.now - get_value_by_name(TIME_ORDER_WARNING).to_i.days
  end

  #
  # numero de dias para una orden no vencida
  #
  def self.time_order_unexpired
    get_value_by_name(TIME_ORDER_UNEXPIRED).to_i
  end

  #
  # numero de dias para una orden VENCIDO
  #
  def self.time_order_expired
    get_value_by_name(TIME_ORDER_EXPIRED).to_i
  end

  #
  # numero de dias para una orden POR VENCER 
  #
  def self.time_order_warning
    get_value_by_name(TIME_ORDER_WARNING).to_i
  end


  #
  # Ancho de cuarto de pliego
  #
  def self.width_quarter_sheet
     by_page_size_type = PageSizeType.find_by_base_dimension(true)
     by_page_size_type ? by_page_size_type.side_dimension_x : get_value_by_name(WIDTH_QUARTER_SHEET).to_f
  end

  #
  # Alto de cuarto de pliego
  #
  def self.height_quarter_sheet
    by_page_size_type = PageSizeType.find_by_base_dimension(true)
    by_page_size_type ? by_page_size_type.side_dimension_y : get_value_by_name(WIDTH_QUARTER_SHEET).to_f
  end

  #
  # margen de corte para Ancho de cuarto de pliego
  #
  def self.margin_cut_width_quarter_sheet
    get_value_by_name(MARGIN_CUT_WIDTH_QUARTER_SHEET).to_f
  end

  #
  # margen de corte para Alto de cuarto de pliego
  #
  def self.margin_cut_height_quarter_sheet
    get_value_by_name(MARGIN_CUT_HEIGHT_QUARTER_SHEET).to_f
  end

  #
  # Impuesto IVA
  #
  def self.tax
    get_value_by_name(TAX).to_f
  end

  #
  # Impuesto IVA porcentaje
  #
  def self.tax_percentage
    get_value_by_name(TAX).to_f/100
  end

  #
  # Impuesto IVA porcentaje
  #
  def self.tax_percentage
    get_value_by_name(TAX).to_f/100
  end

  #
  # Valor minimo de cuarto de pliego
  #
  def self.min_quarter_sheet
    get_value_by_name(MIN_QUARTER_SHEET).to_f
  end

	#
  # Valor maximo de cuarto de pliego
  #
  def self.max_quarter_sheet
    get_value_by_name(MAX_QUARTER_SHEET).to_f
  end

  #
  # Valor minimo de porcentaje para el anticipo
  #
  def self.min_percentage_advanve_payment
    get_value_by_name(MIN_PERCENTAGE_ADVANCE_PAYMENT).to_i
  end

  #
  # Valor moneda actual
  #
  def self.currency
    get_value_by_name(CURRENCY)
  end

	#
	# Tiemp pra expirar o vecer un presupuesto
	#
	def self.expiry_budget
		get_value_by_name(EXPIRY_BUDGET)
	end

	#
	# Dias en un año
	#
 	 def self.days_in_year(year=Date.today.year)
		 Date.new(y=year,m=12,d=31).yday
	 end
	#
	#
	#
	 def self.weeks_in_year(year=Date.today.year)
		 self.days_in_year(year)/7
	 end

	#
	# Lunes en un determinado mes y año
	#
	 def self.mondays_in_month(init_day,end_date,month,year=Date.today.year)
		 last_day = Date.civil(year, month, end_date.to_i).day
		 mondays_days = 0
		 for day in init_day.to_i..last_day
			mondays_days += (Time.local(year, month, day).strftime("%u").eql?("1") ? 1 : 0)
		 end
		 mondays_days
	 end

	 #
	 # Sabados, domingos y dias feriados entre dos fechas
	 #
	 def self.weekends_or_holidays(start_date,end_date)
		 weekends = [0,6]
		 (start_date..end_date).to_a.select {|k| weekends.include?(k.wday)}
	 end


	 #
	 # Sabados, domingos y dias feriados entre dos fechas
	 #
	 def self.weekdays(start_date,end_date)
		 weekends = [0,6]
		 (start_date..end_date).to_a.select {|k| !weekends.include?(k.wday)}
	 end


		#
		# Inicio JOrnada Laboral
		#
	 def self.start_workday
			get_value_by_name(START_WORKDAY)
	 end

	 #
	 # Numero de cuentya FAOV
	 #
	 def self.faov_account
		 account = get_value_by_name(FAOV_ACCOUNT)
		 account.nil? ? "V0000000000000000000" : account
	 end

	  #
		# Numero de dias de pago de dnomina
		#
		def self.payroll_days
			value = get_value_by_name(PAYROLL_DAYS)
			value.nil? ? 30 : value.to_f
	 end

	  #
		# Numero de dias de pago de quincena
		#
		def self.payroll_fortnight
			value = get_value_by_name(PAYROLL_FORTNIGHT)
			value.nil? ? 15 : value.to_f
	 end

		#
		# Aciones por defecto
		#DEFAULT_ACTIONS_CONTROLLER
		def self.default_acctions_controller
			get_value_by_name(DEFAULT_ACTIONS_CONTROLLER).split(",").map(&:strip)
		end

		#
		# Nivel del plan de cuentas
		#
		def self.accountant_account_level
			get_value_by_name(ACCOUNTANT_ACCOUNT_LEVEL).to_i
		end

    #
    # Tipo de personas naturales
    #
    def self.identification_personal_type
      ["V","E"]
    end

end
