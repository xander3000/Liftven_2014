class Budget < ActiveRecord::Base
  attr_accessor :side_dimension_x
  attr_accessor :side_dimension_y
  attr_accessor :advance_payment_process

   humanize_attributes  :client => "Cliente",
                        :price_list => "Lista de precio",
                        :client_discount_type => "Descuento",
                        :client_reputation_type => "Reputación",
                        :base => "Presupuesto",
												:responsible => "Responsable de la orden",
                        :delivery_date => "Fecha de entrega",
												:delivery_time => "Hora de entrega",
                        :payment_method_type => "Forma de pago",
                        :transaction_number => "Número de transacción",
                        :advance_payment => "Anticipo",
                        :transaction_date => "Fecha de transacción",
                        :with_advance_payment => "Procesar orden con anticipo",
												:discount_percent => "Porcentaje de descuento",
												:increase_percent => "Porcentaje de incremento",
												:cash_bank_pos_card_terminal => "Punto de Venta",
												:invoice_printing_type => "Forma de impresión",
												:created_at => "Fecha de creación",
												:id => "Presupuesto",
												:tax => "IVA",
												:balance => "Balance"


  MIN_AMOUNT = 1

  has_one :invoice,:foreign_key => "from_budget_id",:conditions => {:is_advance_payment => false}
  has_one :doc,:as => :category
	has_one :accounting_receivable_account,:as => :doc,:class_name => "Accounting::ReceivableAccount"
  belongs_to :client
  belongs_to :user
	belongs_to :cash_bank_pos_card_terminal,:class_name => "CashBank::PosCardTerminal"
  belongs_to :payment_method_type
	belongs_to :invoice_printing_type
	belongs_to :invoice_of_advance_payment,:class_name => "Invoice"
  has_many :product_by_budgets
	

  after_save  :send_notification_email
	after_save	:create_receivable_account

  validates_presence_of :client,:message => "no registrado"
  validates_presence_of :delivery_date,:delivery_time,:responsible,:if => Proc.new { |budget| budget.advance_payment_process.eql?("true") or budget.advance_payment_process.eql?(true)}
  validates_presence_of :payment_method_type,:advance_payment,:invoice_printing_type,:if => Proc.new { |budget| (budget.advance_payment_process.eql?("true") or budget.advance_payment_process.eql?(true)) and budget.with_advance_payment }
	validates_presence_of :cash_bank_pos_card_terminal,:if => Proc.new { |budget| budget.payment_method_type and budget.payment_method_type.is_credit_debit_card? }
  validate :payment_advance_cannot_be_lesser_than_min_percentage,:if => Proc.new { |budget| (budget.advance_payment_process.eql?("true") or budget.advance_payment_process.eql?(true)) and budget.with_advance_payment}
  validates_presence_of :transaction_number,:transaction_date,:if => Proc.new { |budget| (budget.advance_payment_process.eql?("true") or budget.advance_payment_process.eql?(true)) and budget.with_advance_payment and budget.payment_method_type and budget.payment_method_type.require_additional_information }
	validates_numericality_of :increase_percent,:discount_percent,:less_than_or_equal_to => 100,:greater_than_or_equal_to => 0
	before_validation :set_transaction_date_defalult_value

#	after_update :create_invoice_for_advance_payment


	#
	# Setear fecha actual en caso de que transaction_date sea blanco
	#
	def set_transaction_date_defalult_value
		self.transaction_date = Time.now.strftime("%Y-%m-%d") if self.transaction_date.nil? or self.transaction_date.blank?
	end


  #
  # Envia un correo electronico con el detalle del presupuesto
  #
  def send_notification_email

  end

  #
  # Codigo del presupuesto
  #
  def code
    "%05d" % id
  end

	#
  # Identificacion por Nombre del presupuesto
  #

  def name
    "Presupuesto #{code}"
  end

	#
  # Identificacion por Nombre del presupuesto
  #

  def full_name
    "Presupuesto #{code} / SubTotal: #{sub_total.to_currency(false)} / IVA: #{tax.to_currency(false)} / TOTAL: #{total.to_currency}"
  end


#  #
#  # Calcula el impuesto
#  #
#  def tax
#    return 0 if self.sub_total.nil?
#    self.sub_total*AppConfig.tax_percentage
#  end

  #
  # Calcula el sub_total y total del presupuesto
  #
  def set_values_sub_total_total
    aux_sub_total = 0
    product_by_budgets.each do |product_by_budget|
      aux_sub_total += product_by_budget.total_price
    end
    self.sub_total = aux_sub_total
    self.tax = self.sub_total*AppConfig.tax_percentage
		aux_sub_total = self.sub_total + tax
    self.total = aux_sub_total + (aux_sub_total*self.increase_percent/100) - (aux_sub_total*self.discount_percent/100)
		self.balance =self.total
    self.save
  end

  #
  # Obtiene el caso asociado al presupuesto
  #
  def caso
    doc.case
  end

  #
  # Obtiene la orden o pedido asociado
  #
  def order
    return nil unless has_order?
    caso.docs.first(:conditions => {:category_type => Order.to_s}).category
  end

	#
  # Obtiene las ordenes
  #
  def orders
		result = []
		docs = Doc.all(:conditions => {:category_type => Budget.to_s,:category_id => id})
    docs.each do |doc|
				result << doc.case.order
		end
		result
  end


	#
	# Balance actual SubTotal menos balance
	#
	def current_balance
		total - balance
	end


	#
	# Devuelte el total em monto de los presupuestos del dia con anticipos por tipo de pago
	#
	def self.total_amount_today_transaction_with_advance_payments(today=Time.now.strftime("%Y-%m-%d"),options={})
		today=Time.now.strftime("%Y-%m-%d") if today.nil?
		totals = {}
		all = 0
		#TODO: Arreghlar este select
		budgets_id = Order.all(:conditions => ["created_at >= ? AND created_at <= ?","#{today} 00:00:00","#{today} 23:59:59"]).map(&:caso).map(&:budget).uniq.map(&:id)
		PaymentMethodType.find_all_by_daily_cash_closing.each do |payment|
			if options.has_key?(:only_records)
				totals[payment.tag_name] = all(:conditions => ["id IN (?) AND payment_method_type_id = ? AND with_advance_payment = ? AND invoice_of_advance_payment_id IS NULL",budgets_id, payment.id,true])
			else
				totals[payment.tag_name] = sum(:advance_payment,:conditions => ["id IN (?) AND payment_method_type_id = ? AND with_advance_payment = ? AND invoice_of_advance_payment_id IS NULL",budgets_id, payment.id,true]).to_f.round(2)
				all +=  totals[payment.tag_name]
			end
			
			
			
		end
		totals["all"] = all
		totals["today"] = today
		totals
	end

	#
	# Listado de Presupuestos
	#
	def self.all_paginate(options={})
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "budgets.created_at"
    options[:rp] = options[:rp] || 5
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "budgets.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


    joins = [:client => [:contact_category => [:contact]]]

      clausules = []
      values = []
      conditions  = []

			conditions << "DATEDIFF(NOW() , created_at) <= ?"
			clausules << AppConfig.expiry_budget
      conditions << clausules.join(" AND ")
      conditions.concat( values )
      budgets = all(:conditions => conditions,:joins => joins,:group => "budgets.id",:order => "#{options[:sortname]} #{options[:sortorder]}")
      budgets_paginate = budgets.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      {:count => budgets.size,:paginate => budgets_paginate}
  end

	#
	# Buscador de Presupuestos
	#
	def self.search(term,options={})
    options[:sortorder] = options[:sortorder] || "desc"
    options[:sortname] = options[:sortname] || "budgets.id"
    options[:rp] = options[:rp] || 15
    options[:page] = options[:page] || 1
    options[:qtype] = options[:qtype] || "budgets.id"
    options[:query] = options[:query] || ""
    options[:date] ||=Date.today.year


    joins = [:client => [:contact_category => [:contact]]]


      clausules = []
      values = []
      conditions  = []

      clausules << "(budgets.id = ? OR contacts.identification_document LIKE ?)"
      values << "#{term}"
      values << "%#{term}"

      conditions << clausules.join(" AND ")
      conditions.concat( values )
      budgets = all(:conditions => conditions,:joins => joins,:group => "budgets.id",:order => "#{options[:sortname]} #{options[:sortorder]}")
      budgets_paginate = budgets.paginate(:page => options[:page], :per_page => options[:rp],:conditions => conditions,:joins => joins,:order => "#{options[:sortname]} #{options[:sortorder]}")
      {:count => budgets.size,:paginate => budgets_paginate}
  end



  #
  # Verifica si existe un caso creador a este presupuesto
  #
  def has_case?
    return false if doc.nil?
    !caso.nil?
  end

  #
  # Verifica si existe una orden o pedido a este presupuesto
  #
  def has_order?
    return false unless has_case?
    !caso.docs.first(:conditions => {:category_type => Order.to_s}).nil?
  end

	#
	# Verifica si
	#
	def valid_without_register?
		errors.clear

		run_callbacks(:validate)
		validate

		run_callbacks(:validate_on_update)
		validate_on_update
		errors.empty?
	end

  #
  # Verifica si existe una factura a este presupuesto
  #
  def has_invoice?
    !invoice.nil?
  end

	#
	# Porcentaje del eanticipo
	#
	def percentage_subtotal_advance_payment
		subtotal_advance_payment_v = advance_payment/(1+AppConfig.tax_percentage)
		(subtotal_advance_payment_v*100/sub_total)
	end


	#
	# Crear cuanta por cobrar si el balance es > 0
	#
	def create_receivable_account
				#Accounting::ReceivableAccount
				if balance > 0 and has_order?
					receivable_account = Accounting::ReceivableAccount.new
					receivable_account.doc = self
					receivable_account.client = client
					#receivable_account.payment_method_type = payment_method_type
					receivable_account.date_doc = created_at.to_date.to_s
					receivable_account.date_doc_expiration = delivery_date
					receivable_account.note = "Presupuesto #{id.to_code}"
					receivable_account.sub_total = sub_total
					receivable_account.tax = tax
					receivable_account.total = total
					receivable_account.paid = advance_payment.to_f
					receivable_account.balance = balance
					receivable_account.cashed = false
					receivable_account.valid?
					if receivable_account.valid?
						receivable_account.save
					end
				end
	end
	#
	# Crear una factura para el anticipo
	#
	def create_invoice_for_advance_payment
		if with_advance_payment
				#Invoice
				percentage_subtotal_advance_payment_v = percentage_subtotal_advance_payment

				invoice_v = Invoice.new
				invoice_v.client = client
				invoice_v.is_advance_payment = true
				invoice_v.user = user
				invoice_v.currency_type = CurrencyType.default
				invoice_v.invoice_printing_type = invoice_printing_type
			#ProductByInvoice
			if invoice_v.valid?
					invoice_v.save
					update_attribute(:invoice_of_advance_payment_id, invoice_v.id)
			    product_by_budgets.each do |product_by_budget|
						attributes_product_by_invoice = product_by_budget.attributes
						attributes_product_by_invoice.delete("id")
						attributes_product_by_invoice.delete("budget_id")
						attributes_product_by_invoice.delete("created_at")
						attributes_product_by_invoice.delete("updated_at")
						product_by_invoice_v = ProductByInvoice.new(attributes_product_by_invoice)
						product_by_invoice_v.unit_price = product_by_invoice_v.unit_price*percentage_subtotal_advance_payment_v/100
						product_by_invoice_v.total_price = product_by_invoice_v.total_price*percentage_subtotal_advance_payment_v/100
						product_by_invoice_v.invoice = invoice_v
						product_by_invoice_v.save
						
						product_by_budget.product_component_by_budgets.each do |product_component_by_budget|
							attributes_product_component_by_invoice = product_component_by_budget.attributes
							attributes_product_component_by_invoice.delete("id")
							attributes_product_component_by_invoice.delete("product_by_budget_id")
							product_component_by_invoice_v = ProductComponentByInvoice.new(attributes_product_component_by_invoice)
							product_component_by_invoice_v.product_by_invoice = product_by_invoice_v
							product_component_by_invoice_v.save
						end
						product_by_budget.accesory_component_by_budgets.each do |accesory_component_by_budget|
							attributes_accesory_component_by_invoice = accesory_component_by_budget.attributes
							attributes_accesory_component_by_invoice.delete("id")
							attributes_accesory_component_by_invoice.delete("product_by_budget_id")
							accesory_component_by_invoice_v = AccesoryComponentByInvoice.new(attributes_accesory_component_by_invoice)
							accesory_component_by_invoice_v.product_by_invoice = product_by_invoice_v
							accesory_component_by_invoice_v.save
						end
					end
				invoice_v.set_values_sub_total_total(true)
				incoming_invoice_billing = IncomingInvoiceBilling.new
				incoming_invoice_billing.amount = advance_payment
				incoming_invoice_billing.payment_method_type = payment_method_type
				incoming_invoice_billing.cash_bank_pos_card_terminal = cash_bank_pos_card_terminal
				#incoming_invoice_billing.is_advance_payment = true
				incoming_invoice_billing.transaction_reference = transaction_number
				incoming_invoice_billing.transaction_date = transaction_date
				incoming_invoice_billing.invoice = invoice_v
				incoming_invoice_billing.save
        #BEGIN: create_receivable_account for invoice
          invoice_v.reload
          invoice_v.create_receivable_account
        #END: create_receivable_account for invoice
			end
			invoice_v.reload
			if(invoice_v.fiscal_printed?)
					invoice_v.print
				elsif(invoice_v.free_printed?)
					invoice_v.was_printed
			end
		end
	end

	#
	#
	#
	def has_invoice_for_advance_payment?
		!invoice_of_advance_payment.nil?
	end
  #
  # Asociar una order
  #
  def generate_order(options={})
#    product_by_budgets_aux = product_by_budgets
#    product_by_budget_first = product_by_budgets_aux.shift
    attr_order = {
      :client_id => client_id,
      :user => options[:current_user],
      :delivery_date => delivery_date
    }
    options_order = {
        :user_tracker => User.first_lower_load,
        :user => options[:current_user]
    }
    success = true
    product_by_budgets.each do |product_by_budget|
			attr_order[:associate_id] = product_by_budget.id
			attr_order[:associate_type] = product_by_budget.class.to_s

      options_order[:subject_case] = "#{product_by_budget.quantity} #{product_by_budget.product.name}"
      options_order[:note_case] = "#{product_by_budget.elements_products_description_inline}"
      
      result = Order.guardar(attr_order,options_order)
      success &= result[:success]
      if success
        order = result[:object]
        associate_case(order.caso)
				associate_digital_card(order.caso, product_by_budget) if product_by_budget.has_digital_card?
      end
    end
    
    {:success => success,:order => order}
  end



  #
  # Asocia un caso al presupuesto
  #
  def associate_case(caso)
       object_doc = Doc.new
       object_doc.case = caso
       object_doc.category = self
       object_doc.save
  end

  #
  # Asocia un diseño digital a la orden
  #
  def associate_digital_card(caso,product_by_budget)
       object_doc = Doc.new
       object_doc.case = caso
       object_doc.category = product_by_budget.digital_card
       object_doc.save
  end

  #
  # Agregar error al no poseer productos asociados
  #
  def add_error_empty_products
    errors.add_to_base("debe seleccionar al menos un producto")
  end


  #
  # Busca todas las cotizaciones creadas y llleva json
  #

  def self.all_to_json(options={})
    data = []
    names = []
    last_year = Time.now - 1.year
    count(:select => "created_at",:conditions => ["(date_format(created_at, '%Y%M')) >= ?",last_year.strftime("%Y%m")],:group => "date_format(created_at, '%Y/%M')").to_a.each do |item|
      
      names << item.first
      data << item.last
    end
    JSON.generate("NAME" => "Presupuestos", "CATEGORIES" => names,"DATA" => data)
    #rows
  end

  #
  # Retorna true si posee adelanto
  #
  def has_advance_payment?
    !payment_method_type.nil?
  end

	#
	# Nombre del modelo
	#
	def self.model_humanize_name
		"Presupuesto"
	end


  #
  # Valida si el anticipo es mas del defino en MIN_PERCENTAGE_ADVANCE_PAYMENTE
  #
  def payment_advance_cannot_be_lesser_than_min_percentage
      min_percentage_advanve_payment = AppConfig.min_percentage_advanve_payment
      min_advance_payment = min_percentage_advanve_payment*total.to_f/100

      if min_advance_payment >  advance_payment.to_f
        errors.add(:advance_payment, "no puede ser menor al #{min_percentage_advanve_payment}% de #{total.to_currency}")
      end
  end

  def self.act
    all.each do |bud|
      bud.set_values_sub_total_total
      bud.save
    end
  end

end

