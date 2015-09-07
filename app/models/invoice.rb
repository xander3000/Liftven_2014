class Invoice < ActiveRecord::Base
  attr_accessor :side_dimension_x
  attr_accessor :side_dimension_y
  attr_accessor :discount


 humanize_attributes  :payment_method_type => "Forma de pago",
                      :transaction_number => "Numero de transaccion",
                      :advance_payment => "Anticipo",
                      :transaction_date => "Fecha de transaccion",
											:id => "Numero de documento",
											:created_at => "Fecha de facturación",
											:client => "Cliente",
											:currency_type_short => "Mo.",
											:only_issue => "Solo emisión de factura",
											:base => "Factura",
											:incoming_invoice_billings => "Pagos",
											:invoice_printing_type => "Forma de impresión",
											:discount_percent => "Porcentaje de descuento",
											:increase_percent => "Porcentaje de incremento",
											:date => "Fecha"

  MIN_AMOUNT = 1


  belongs_to :client

  belongs_to :from_budget,:class_name => "Budget"#,:conditions => {:invoice_of_advance_payment_id => nil}
	#belongs_to :from_budget_with_receivable_account,:class_name => "Budget",:conditions => ["invoice_of_advance_payment_id is not null"],:foreign_key => "from_budget_id"
  belongs_to :user
	belongs_to :currency_type
	belongs_to :invoice_printing_type
	has_one :accounting_receivable_account,:as => :doc,:class_name => "Accounting::ReceivableAccount"
  has_many :product_by_invoices
  has_many :tracking_states,:as => "proxy"
	has_many :incoming_invoice_billings,:order => "id DESC"

  validates_presence_of :client
  validates_presence_of :invoice_printing_type,:if => Proc.new { |invoice| !invoice.only_issue }
	validates_numericality_of :increase_percent,:discount_percent,:less_than_or_equal_to => 100,:greater_than_or_equal_to => 0
  validate :print_with_client_islr

	after_save  :set_associate_case_from_budget
	
	#after_save	:create_receivable_account
	#after_save  :cancel_receivable_account_from_budget

	named_scope :all_actives_by_client, lambda { |client_id| {:conditions => {:client_id => client_id} }}#

  



  #
  # Codigo de factura
  #
  def code
    "%05d" % id
  end


  #
  # Identificacion por Nombre de la factura
  #

  def name
    "##{code} (#{I18n.l(created_at,:format => :long_date)})"
  end

	#
  # Identificacion por Nombre de la factura
  #

  def full_name
    "Factura / #{code}"
  end

  #
  # Calcula el sub_total y total de la factura
  #
  def set_values_sub_total_total(autosave=true)
    aux_sub_total = 0
    product_by_invoices.each do |product_by_invoice|
      aux_sub_total += product_by_invoice.total_price
    end
    self.sub_total = aux_sub_total.round(2)
    self.total = (self.sub_total + applicable_taxes_withholdings).round(2)
		self.balance = current_balance_with_ready_cash
    self.save if autosave
  end
#
#  #
#  # Calcula el impuesto
#  #
#  def tax
#    return 0 if self.sub_total.nil?
#    self.sub_total*AppConfig.tax_percentage
#  end

	#
	#Verifica si la factura tiene le retencion de ISLR
	#
	def applicable_withholding_islr?
		client.contact.islr_retained
	end

  #
  # Si la factura es generada a partid de un presupeusto y este tiene caso asociado, se asocia la factura a un caso
  #
  def set_associate_case_from_budget
		options = {
			:user => user
		}
    budget = self.from_budget
    if budget and budget.caso
      self.associate_case(budget.caso)
			cancel_receivable_account_from_budget
			budget.orders.each do |caso|
					caso.to_close(options)
			end
    end
  end

  #
	# Verifica si la factura esta por pagar
	#
	def is_payable?
		!balance.zero?
	end

  #
	# Coneviret su valores  ahash
	#
	def to_hash
		{"reference"=>transaction_number, "description"=>full_name, "reference_document_type"=> self.class.to_s, "amount"=>total, "control_number"=>transaction_number, "reference_document_id"=>id}
	end


	#
	# Crear cuanta por cobrar si el el tipo de forma de pago es por cobrar
	#
	def create_receivable_account
		incoming_invoice_billings.each do |incoming_invoice_billing|
				#Accounting::ReceivableAccount
			if PaymentMethodType.all_receivable.include?(incoming_invoice_billing.payment_method_type.tag_name)
					receivable_account = Accounting::ReceivableAccount.new
					receivable_account.doc = self
					receivable_account.client = client
					receivable_account.payment_method_type = incoming_invoice_billing.payment_method_type
					receivable_account.date_doc = created_at.to_date.to_s
					receivable_account.date_doc_expiration = created_at.to_date.to_s
					receivable_account.note = "Factura #{id.to_code}"
					receivable_account.sub_total = sub_total
					receivable_account.tax = tax
					receivable_account.total = total
					receivable_account.paid = total - current_balance_with_ready_cash
					receivable_account.balance = current_balance_with_ready_cash
					receivable_account.cashed = false
					receivable_account.valid?
					if receivable_account.valid?
						receivable_account.save
					end
			end
				end
	end

	#
	# Verific asi con el balace actual la cuenta por cobrar fue saldada
	#
	def verify_debit_account_is_finished
		if accounting_receivable_account
			accounting_receivable_account.update_attributes(:paid => total - balance,:balance => balance,:cashed => balance.zero?)
		end
	end

	#
	# Anula la cuenta por pagar de existir
	#
	def cancel_receivable_account_from_budget
		budget = self.from_budget#_with_receivable_account
		receivable_account = budget.accounting_receivable_account
		if receivable_account
			receivable_account.update_attributes(:canceled => true)
		end
	end



  #
  # Asocia un caso a la factura
  #
  def associate_case(caso)
       object_doc = Doc.new
       object_doc.case = caso
       object_doc.category = self
       object_doc.save
  end
	
  #
  # Agregar error al no poseer productos asociados
  #
  def add_error_empty_products
    errors.add_to_base("debe seleccionar al menos un producto")
  end

  #
  # Agregar error al no poseer pagos
  #
  def add_error_empty_billings
    errors.add_to_base("debe completar los pagos")
  end

	#
	# Calucla los impuestos y retenciones si aplica
	#
	def applicable_taxes_withholdings
		total_taxes_withholding = 0
		tax_aux = AppConfig.tax_percentage*self.sub_total
		retention_islr_aux = client.contact.retention_rate_islr/100*tax_aux
		retention_islr_2_aux = client.contact.retention_rate_islr_2/100*self.sub_total
		total_taxes_withholding += tax_aux

#		total_taxes_withholding -= retention_islr_aux
#		total_taxes_withholding -= retention_islr_2_aux

		self.tax = tax_aux
		self.retention_islr = retention_islr_aux
		self.retention_islr_2 = retention_islr_2_aux
		total_taxes_withholding.round(2)
	end

	#
	# Valida si el monto total de los pagos sobrepasa alncanzal en monto de la factura
	#
	def reached_maximum_amount?(billings,product_by_invoices)
		self.sub_total = product_by_invoices.map(&:total_price).to_sum.to_f.round(2)
		self.total = (self.sub_total + applicable_taxes_withholdings).round(2)#total_product_by_invoices*AppConfig.tax_percentage
		success = true
		if billings.map(&:amount).to_sum.to_f.round(2) > self.total
			errors.add(:incoming_invoice_billings,"execede el total de la factura: #{billings.map(&:amount).to_sum.to_f.round(2)}/#{self.total.round(2)}")
			success = false
		end
		success
	end

	#
	# Valida si el monto total de los pagos no alncanzal en monto de la factura
	#
	def reached_minimum_amount?(billings,product_by_invoices)
		self.sub_total =  product_by_invoices.map(&:total_price).to_sum.to_f.round(2)
		self.total = (self.sub_total + applicable_taxes_withholdings).round(2)#+=total_product_by_invoices*AppConfig.tax_percentage
		success = true
		if billings.map(&:amount).to_sum.to_f.round(2) < self.total
			errors.add(:incoming_invoice_billings,"no cubre el total de la factura: #{billings.map(&:amount).to_sum.to_f}/#{self.total.round(2)}")
			success = false
		end
		success
	end


  #
  # Crear el estatus de la factura
  #
  def add_tracking_states(options={})
      attr = {
        :proxy_id => id,
        :proxy_type => self.class.to_s,
        :user_id => options[:user_id]
      }
      object = TrackingState.new(attr)
      if options.has_key?(:state)
        object.state = options[:state]
      else
       if(PaymentMethodType.all_receivable.include?(payment_method_type.tag_name))
         object.state = State.find_by_apply_to_and_name(self.class.to_s,State::POR_COBRAR)
       else
         object.state = State.find_by_apply_to_and_name(self.class.to_s,State::COBRADO)
       end
      end
      success = object.valid?
#      p object.errors.each { |e,r| puts "#{e}: #{r}" }
      if success
        object.proxy = self
        object.save
      end
  end

  #
  # Obtener el ultimo tracking estado actual
  #
  def actual_tracking_state
    tracking_states.first(:conditions => {:actual => true})
  end

  #
  # Obtener el ultimo Estatus
  #
  def actual_state
    actual_tracking_state.state
  end

  #
  # Esat vencido
  #
  def is_expired?
    (actual_state.name.eql?(State::POR_COBRAR) and (Date.parse(Time.now.to_s).mjd - Date.parse(updated_at.to_s).mjd) > payment_method_type.expiration_days)
  end

  #
  # Tienne un prseupuesto
  #
  def has_budget?
    !from_budget.nil?
  end

  #
  # Exporta a XLS
  #
  def as_xls(options = {})
    hash = {
        "Codigo" => id.to_code,
        "Monto" => total,
        "Fecha de Emisión" => created_at.to_date,
        "Fecha de Vencimiento" => created_at.to_date,
        "Estatus" => actual_state.name
        
    }
    case options[:report]
      when "2"
        hash["Cliente"] = client.contact.name
      when "4"
        hash["Producto"] = product_by_invoices.map(&:product).map(&:name).uniq.join(",")
    end
    hash
  end

	#
	#Balance actual de la factura
	#
	def current_balance
		total.to_f.round(2) - amount_payments
	end

	#
	#Balance actual de la factura con pagos 
	#
	def current_balance_with_ready_cash
		self.total.to_f.round(2) - amount_payments_with_ready_cash
	end

	#
	# Tiene pagos registrados
	#
	def has_incoming_invoice_billings?
		!incoming_invoice_billings.empty?
	end

	#
	# Total en pagos
	#
	def amount_payments
		incoming_invoice_billings.map(&:amount).to_sum.to_f.round(2)
	end

	#
	# Total en pagos con pagos efectivos
	#
	def amount_payments_with_ready_cash
		total_paid = 0

		incoming_invoice_billings.each do |incoming_invoice_billing|
			if PaymentMethodType.all_ready_cash.include?(incoming_invoice_billing.payment_method_type.tag_name)
					total_paid = incoming_invoice_billing.amount
			end
		end
		total_paid.to_f.round(2)
	end

	#
	# Fue impresa por impresion fiscal
	#
	def fiscal_printed?
		return false if only_issue
		invoice_printing_type.tag_name.eql?(InvoicePrintingType::FISCAL)
	end

	#
# Fue impresa por impresion formato libre
	#
	def free_printed?
		return false if only_issue
		invoice_printing_type.tag_name.eql?(InvoicePrintingType::LIBRE)
	end

	#
	# Imprime la factura en impresora fical
	#
	def print
		hostname = PRINTER_HOST
		port = PRINTER_PORT
		logger.info "********* Invoice(#{id}).print *********"
		logger.info "\tOPEN CONNECTION WITH #{hostname}:#{port}"
		s = TCPSocket.open(hostname, port)
		logger.info "\tWRITE CONNECTION: invoice,#{id}"
		logger.info "****************************************"
		s.write("invoice,#{id}")
#		logger.info "RESPONSE: #{s.gets}"
		s.close
		#reload
		#if(!printed?)
		#	errors.add_to_base("hubo un problema con la impresion")
		#end
		#printed?
	end

	#
	# Actualzia indicando que la factura fue impresa
	#
	def was_printed
		update_attribute(:printed, true)
	end

	#
	# Fue impresa
	#
	def printed?
		printed
	end

	#
	# Validate si la impresora seleccionada puede imprimir ISLR
	#
	def print_with_client_islr
		if(client and client.contact.islr_retained and invoice_printing_type and !invoice_printing_type.can_print_islr?)
			errors.add(:invoice_printing_type,"no esta configurada para la impresión del ISLR")
			return false
		end
		true
	end

	#
	# Accion al definir un movimiento bancario
	#
	def bank_movement_register

	end


	#
	# Todas las facturas pendientes
	#
	def self.all_for_paid
		self.all(:conditions => ["balance > 0"])
	end

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Factura por venta"
	end
	
	#
	# Impresion del reporte Z
	#
	def self.report_z
		today = Time.now.strftime("%Y-%m-%d")
		daily_cash_opening = CashBank::DailyCashOpening.first(:conditions => {:date => today})
		return {:success => false,:message => "No hay apertura de caja para el dia de hoy"} if daily_cash_opening.nil?
		if not daily_cash_opening.closed_by_fiscal
			hostname = PRINTER_HOST
			port = PRINTER_PORT
			s = TCPSocket.open(hostname, port)
			s.write("report-z,#{daily_cash_opening.id}")
			s.close
		elsif daily_cash_opening.closed
			return {:success => false,:message => "Se ha cerrado la caja por el dia de hoy"}
		else
			return {:success => true,:message => "Ya se ejecutó el cierre fiscal el día de hoy"}
		end
		{:success => true,:message => ""}
	end

	#
	# todas Por mes y año
	#
	def self.all_group_by_month_year(year=Time.now.year)
		group_by_month_year = {}
		Date::MONTHNAMES.each_index do |index|
			if index > 0
				condition_month_year = "#{year}-#{index.to_code("02")}"
				result = first(:select => "SUM(sub_total) AS sub_total,SUM(tax) AS tax,SUM(total) AS total",:conditions => ["date LIKE ?","#{condition_month_year}-%"])
				group_by_month_year[condition_month_year] =  {:sub_total => result.sub_total.to_f,:tax => result.tax.to_f,:total => result.total.to_f}
			end
		end
		group_by_month_year.sort
	end
  
	#
	# todas Por mes y año
	#
	def self.all_by_month_year(month_year)
			all(:conditions => ["date LIKE ? ","#{month_year}-%"],:order => "id ASC")
	end

	#
	# Busqueda por criterio
	#
	def self.all_by_criterion(options={})
			clausules = []
      values = []
      conditions  = []
			categories = []
			results = []


		if !options[:finished_product_category_type].eql?("")
			categories = [FinishedProductCategoryType.find(options[:finished_product_category_type])]
		else
			categories = FinishedProductCategoryType.all
		end


		if !options[:date_from].eql?("")
			clausules << "date >= ?"
			values << options[:date_from]
		end

		if !options[:date_to].eql?("")
			clausules << "date <= ?"
			values << options[:date_to]
		end


		clausules_aux = clausules.clone
		values_aux = values.clone
		categories.each do |category|
			conditions  = []
			clausules = clausules_aux.clone
			values = values_aux.clone
			clausules << "products.finished_product_category_type_id = ?"
			values << category.id
			conditions << clausules.join(" AND ")
			conditions.concat( values )
			results << [category, all(:select =>"products.name AS product_name, sum(invoices.total) AS sum ,count(invoices.id) AS count",:conditions => conditions,:joins => [:product_by_invoices => [:product]],:group => "products.name")]
		end

		results
	end
	
  def self.generate
    max = 6500
    min = 1000
    120.times.each do |i|
      a = new(:client_id => 1,:sub_total =>(rand * (max-min) + min),:total => (rand * (max-min) + min))
      a.save
    end
  end

end
