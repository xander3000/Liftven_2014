class Backend::InvoicesController < Backend::BaseController
  helper_method :current_client

	before_filter :defaults
#	before_filter :validate_responsible,:only => [:new,:create]
#	before_filter :validate_daily_cash_opening,:only => [:new,:new_daily_cash_closing]
#	before_filter :validate_if_can_new_invoice,:only => [:new]



  def index
    @invoices = Invoice.all(:conditions => ["DATEDIFF(NOW() , created_at) <= ?",20])#_for_paid
  end

  def new
		defaults
    @invoice = Invoice.new
    @client = Client.new
    @contact = Contact.new
    @incoming_invoice_billings = []
    self.current_client_clear
    self.current_product_by_invoices_clear
    self.current_components_by_product_invoices_clear
    self.current_accesories_by_product_invoices_clear
		self.current_incoming_invoice_billings_clear
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user = current_user
		@invoice.currency_type = CurrencyType.default
		@invoice.date = Time.now.to_date
    
    product_by_invoices = self.current_product_by_invoices
    components_by_product_invoices = self.current_components_by_product_invoices
    accesories_by_product_invoices = self.current_accesories_by_product_invoices
		incoming_invoice_billings = self.current_incoming_invoice_billings
    @success = true
    unless current_client
      @contact = Contact.new(params[:contact])
      @contact.associated_with_client
      valid = @contact.valid?
      @success &= valid
      if valid
        @contact.save
        @invoice.client = @contact.client
      end
		else
			@contact = current_client.contact
			@success &= @contact.update_attributes(params[:contact])
    end
    @success &= @invoice.valid?
		@success &= !product_by_invoices.empty?

		@invoice.add_error_empty_products if product_by_invoices.empty?
		if !@invoice.only_issue
			@invoice.add_error_empty_billings if incoming_invoice_billings.empty?
			@success &= @invoice.reached_maximum_amount?(incoming_invoice_billings,product_by_invoices)
			@success &= @invoice.reached_minimum_amount?(incoming_invoice_billings,product_by_invoices)
		else
			@invoice.invoice_printing_type_id = 1
		end
	    
    if @success
      @invoice.save
      product_by_invoices.each do |product_by_invoice|
        product_by_invoice.invoice = @invoice
        product_by_invoice.save
        components_by_product_invoices[product_by_invoice[:id_temporal].to_s.to_sym].each do |product_component_type,product_components|
           product_components.each do |product_component|
            product_component_by_invoice = ProductComponentByInvoice.new(product_component)
            product_component_by_invoice.product_by_invoice = product_by_invoice
            product_component_by_invoice.save
           end
        end if components_by_product_invoices[product_by_invoice[:id_temporal].to_s.to_sym]

        accesories_by_product_invoices[product_by_invoice[:id_temporal].to_s.to_sym].each do |accesories_by_invoice|
          accesories_by_invoice.product_by_invoice = product_by_invoice
          accesories_by_invoice.save
        end if accesories_by_product_invoices[product_by_invoice[:id_temporal].to_s.to_sym]
      end

			logger.info "***** BEGIN: SAVE ALL INCOMING INVOICE BILLING(#{incoming_invoice_billings.size}) FOR INVOICE #{@invoice.id} ******"
			incoming_invoice_billings.each do |incoming_invoice_billing|
				incoming_invoice_billing.invoice = @invoice
				logger.info "\tSAVE TO : #{incoming_invoice_billing.attributes}"
				logger.info "\t\tRESULT SAVE: #{incoming_invoice_billing.save}"
				incoming_invoice_billing.errors.each {|a,m| logger.info "\t\t\tRESULT ERRORS: #{a}: #{m}" }
			end
			logger.info "***** END: SAVE ALL INCOMING INVOICE BILLING ******"
			@invoice.reload
      @invoice.set_values_sub_total_total
			@invoice.create_receivable_account
			if !@invoice.only_issue
				if(@invoice.fiscal_printed?)
					@invoice.print
				elsif(@invoice.free_printed?)
					@invoice.was_printed
				end
			end
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
    @product_by_invoices = @invoice.product_by_invoices
		@incoming_invoice_billings = @invoice.incoming_invoice_billings
    if @invoice.has_budget?
      @budget = @invoice.from_budget
    end
		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "invoice_#{@invoice.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :margin => {:top                => 18,
                           :bottom             => 30,
													 :right              => 15,
                           :left               => 5
 												 }
			end
		end

  end

  def add_product
    
    params[:product][:id_temporal] = timestamp
    product_by_invoice = ProductByInvoice.new(params[:product])
    @success = product_by_invoice.valid?
    params[:product_component_id].each do |product_component_id,product_components|
      product_components[:id_temporal] = params[:product][:id_temporal]
      product_components[:element_type].each do |element_type_name,element_type_id|
        product_component_by_invoice = ProductComponentByInvoice.new
        product_component_by_invoice[:id_temporal] = params[:product][:id_temporal]
        product_component_by_invoice.product_component_type_id = product_component_id
        product_component_by_invoice.element_id = element_type_id
        product_component_by_invoice.element_type = element_type_name
        if element_type_id.empty?
          product_components[:element_type].delete(element_type_name)
        else
          @success &=  product_component_by_invoice.valid?
        end
        
      end
    end if params[:product_component_id]

    params[:accessories_ids].each do |accesory_id|
      accesory_componet_by_invoice = AccesoryComponentByInvoice.new
      accesory_componet_by_invoice[:id_temporal] = params[:product][:id_temporal]
      accesory_componet_by_invoice.accessory_component_type_id = accesory_id
      @success &=  accesory_componet_by_invoice.valid?
    end if params[:accessories_ids]

    if @success
        self.current_product_by_invoices = params[:product]
        self.current_components_by_product_invoices = {params[:product][:id_temporal] => params[:product_component_id]} if params[:product_component_id]
        self.current_accesories_by_product_invoices= {params[:product][:id_temporal] => params[:accessories_ids]} if params[:accessories_ids]
    end
    @product_by_invoices = self.current_product_by_invoices
    @components_by_invoices = self.current_components_by_product_invoices
    @accesories_by_invoices = self.current_accesories_by_product_invoices
  end

	def get_additional_incoming_invoice_billing_information
		@payment_method_type = PaymentMethodType.find(params[:incoming_invoice_billing][:payment_method_type_id])
		@success = @payment_method_type ? true : false
	end

	def add_incoming_invoice_billing
		@incoming_invoice_billing = IncomingInvoiceBilling.new(params[:incoming_invoice_billing])
		@success  = @incoming_invoice_billing.valid?
		if @success
			self.current_incoming_invoice_billings=params[:incoming_invoice_billing]
		end
		@incoming_invoice_billings = self.current_incoming_invoice_billings
	end
  
  def find_product_components_by_product
    @product = Product.find_by_id(params[:product_id])
    @element_types =Product.elements_types
  end

  def custom_paper_size
    @product_component_type = params[:product_component_type]
    @page_size_type = PageSizeType.find_by_id(params[:value])
  end

  def custom_paper_type
    @product_component_type_id = params[:product_component_type]
    @paper_type = PaperType.find_by_id(params[:value])
    @paper_types = PaperType.all(:conditions => ["tag_name != ?",PaperType::OTRO]) if @paper_type.requiere_other_paper?
  end

  def custom_color_mode_type
    @product_component_type_id = params[:product_component_type]
    @color_mode_type = ColorModeType.find_by_id(params[:value])
  end

  def remove_product_from_invoice
    remove_product
  end


  def remove_product_from_budget
    remove_product
  end

  def remove_product
    self.remove_current_product_by_invoices(params[:id_temporal])
    self.remove_components_by_invoice(params[:id_temporal])
    self.remove_components_by_invoice(params[:id_temporal])
    @product_by_invoices = self.current_product_by_invoices
    @components_by_invoices = self.current_components_by_product_invoices
    @accesories_by_invoices = self.current_accesories_by_product_invoices
  end

	def detail
    @invoice = Invoice.find(params[:invoice_id])
		@incoming_invoice_billing = IncomingInvoiceBilling.new
		@incoming_invoice_billings = @invoice.incoming_invoice_billings
	end

	def add_payment
		@invoice = Invoice.find(params[:invoice_id])
		@incoming_invoice_billing = IncomingInvoiceBilling.new(params[:incoming_invoice_billing])
		@incoming_invoice_billing.invoice = @invoice
		@success = @incoming_invoice_billing.valid?
		
		if @success
			@incoming_invoice_billing.invoice = @invoice
			@incoming_invoice_billing.save
		end
		@invoice.reload
	end

  def change_state
    invoice = Invoice.find(params[:invoice_id])
    new_state = State.find(params[:value])
    invoice.add_tracking_states(:user_id => current_user.id,:state => new_state)
    @invoices = Invoice.all
  end

  def new_invoice_from_budget
    @incoming_invoice_billings = []
    self.current_client_clear
    self.current_product_by_invoices_clear
    self.current_components_by_product_invoices_clear
    self.current_accesories_by_product_invoices_clear
		self.current_incoming_invoice_billings_clear

    budget = Budget.find_by_id(params[:budget_id])
    attributes_invoice = budget.attributes
    attributes_invoice.delete("id")
    attributes_invoice.delete("discount")
    attributes_invoice.delete("created_at")
    attributes_invoice.delete("updated_at")
    attributes_invoice.delete("delivery_date")
		attributes_invoice.delete("delivery_time")
    attributes_invoice.delete("user_id")
    attributes_invoice.delete("with_advance_payment")
    attributes_invoice.delete("payment_method_type_id")
		attributes_invoice.delete("cash_bank_pos_card_terminal_id")
    attributes_invoice.delete("transaction_number")
    attributes_invoice.delete("transaction_date")
    attributes_invoice.delete("responsible")
		attributes_invoice.delete("balance")
		attributes_invoice.delete("tax")
		attributes_invoice.delete("invoice_of_advance_payment_id")
    attributes_invoice["from_budget_id"] = params[:budget_id]
    attributes_invoice["user_id"] = current_user.id
		if budget.has_invoice_for_advance_payment?
			#attributes_invoice["advance_payment"] = 0
			attributes_invoice["sub_total"] = budget.sub_total*(100-budget.percentage_subtotal_advance_payment)/100
			attributes_invoice["total"] = 0#budget.total*(100-budget.percentage_subtotal_advance_payment)/100
		end

    budget.product_by_budgets.each do |product_by_budget|
      id_temporal = timestamp
      attributes_product_by_invoice = product_by_budget.attributes
      attributes_product_by_invoice.delete("id")
      attributes_product_by_invoice.delete("budget_id")
      attributes_product_by_invoice.delete("created_at")
      attributes_product_by_invoice.delete("updated_at")
			if budget.has_invoice_for_advance_payment?
				attributes_product_by_invoice["unit_price"] = product_by_budget.unit_price*(100-budget.percentage_subtotal_advance_payment)/100
				attributes_product_by_invoice["total_price"] = product_by_budget.total_price*(100-budget.percentage_subtotal_advance_payment)/100
			end

      attributes_product_by_invoice[:id_temporal] = id_temporal
      self.current_product_by_invoices = attributes_product_by_invoice
      product_components = {}
      product_by_budget.product_component_by_budgets.each do |product_component_by_budget|
        attributes_product_component_by_invoice = product_component_by_budget.attributes
        product_component_type_id = attributes_product_component_by_invoice["product_component_type_id"]
        product_components[product_component_type_id.to_s] = {:id_temporal => id_temporal} if product_components[product_component_type_id.to_s].nil?
        product_components[product_component_type_id.to_s][:element_type] = {} if product_components[product_component_type_id.to_s][:element_type].nil?
        product_components[product_component_type_id.to_s][:element_type][attributes_product_component_by_invoice["element_type"]] = attributes_product_component_by_invoice["element_id"]
      end
      self.current_components_by_product_invoices = {id_temporal => product_components} if !product_components.empty?
      sleep 0.1
    end

		if budget.has_advance_payment? and !budget.has_invoice_for_advance_payment?
			incoming_invoice_billing = IncomingInvoiceBilling.new
			incoming_invoice_billing.amount = budget.advance_payment
			incoming_invoice_billing.payment_method_type = budget.payment_method_type
			incoming_invoice_billing.cash_bank_pos_card_terminal = budget.cash_bank_pos_card_terminal
			incoming_invoice_billing.is_advance_payment = true
			incoming_invoice_billing.transaction_reference = budget.transaction_number
			incoming_invoice_billing.transaction_date = budget.transaction_date
			self.current_incoming_invoice_billings=incoming_invoice_billing.attributes if incoming_invoice_billing.valid?
		end

		
    self.current_client=(budget.client.id)

    @invoice = Invoice.new(attributes_invoice)
    @invoice.client = budget.client
    @client = budget.client
    @contact = budget.client.contact
    @product_by_invoices = self.current_product_by_invoices
    @components_by_invoices = self.current_components_by_product_invoices
		@incoming_invoice_billings = self.current_incoming_invoice_billings

    @from_budget = true
    @budget = budget
    render :action => "new"
  end

	def print
		@invoice = Invoice.find(params[:invoice_id])
		 @invoice.print
		@success = true
	end

  def get_additional_payment_method_information
    @payment_method_type = PaymentMethodType.find_by_id(params[:incoming_invoice_billing][:payment_method_type_id].to_i)
  end


	def daily_cash_closing
		@daily_cash_closings = CashBank::DailyCashClosing.all
	end

	def show_daily_cash_closing
		@daily_cash_closing = CashBank::DailyCashClosing.find(params[:daily_cash_closing_id])
		@cash_bank_cash_count_movement = @daily_cash_closing.cash_bank_cash_count_movement
		@cash_bank_pos_card_terminal_movement = @daily_cash_closing.cash_bank_pos_card_terminal_movement

		@consolidate_count_positions = @cash_bank_cash_count_movement.consolidate_count_positions
		@consolidate_pos_card_terminal_positions = @cash_bank_pos_card_terminal_movement.consolidate_pos_card_terminal_positions
		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "daily_cash_closing_#{@daily_cash_closing.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :orientation										 => 'Landscape',
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
							 :margin => {:top                => 15,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 }
			end
		end

	end

	def detail_daily_cash_closing
		@daily_cash_closing = CashBank::DailyCashClosing.find(params[:daily_cash_closing_id])
		@payment_method_type_tag_name = params[:payment_method_type_tag_name]

		date = @daily_cash_closing.cash_bank_daily_cash_opening.date
		if @payment_method_type_tag_name.eql?("ADVANCE_PAYMENT")
			@budgets = []
			budgets = Budget.total_amount_today_transaction_with_advance_payments(date, :only_records => true)
			PaymentMethodType.find_all_by_daily_cash_closing.each do |payment|
				@budgets = @budgets.concat(budgets[payment.tag_name])
				@budgets = @budgets.uniq
			end
		else
			@invoices = IncomingInvoiceBilling.total_amount_today_fiscal_transactions(date, :only_records => true)[@payment_method_type_tag_name]
			@invoices = @invoices.concat(IncomingInvoiceBilling.total_amount_today_fiscal_free_form(date, :only_records => true)[@payment_method_type_tag_name])
			@invoices = @invoices.map(&:invoice).uniq
		end
	end

	def new_daily_cash_opening
		if current_user.cash_bank_cash.opening_for_today
			flash[:notice] = "La apertura para la caja <b>#{current_user.cash_bank_cash.name}</b> ha sido satisfactoria!"
		else
			flash[:error] = "La apertura para la caja <b>#{current_user.cash_bank_cash.name}</b> no ha sido satisfactoria"
		end
		redirect_to backend_invoices_url
	end


	def new_daily_cash_closing
		result = Invoice.report_z
		@success = result[:success]
		@message = result[:message]
		if @success
			current_cash_count_position_clear
			current_pos_card_terminal_position_clear
			@daily_cash_closing = CashBank::DailyCashClosing.new
			@cash_count_position = CashBank::CashCountPosition.new
			@pos_card_terminal_position = CashBank::PosCardTerminalPosition.new
			defaults_daily_cash_closing
			flash[:warning] = result[:message] if not result[:message].empty?
		else
			flash[:error] = result[:message]
			redirect_to backend_invoices_url
		end
	end

	def new_daily_cash_closing_with_old_date
			current_cash_count_position_clear
			current_pos_card_terminal_position_clear
			@daily_cash_closing = CashBank::DailyCashClosing.new
			@cash_count_position = CashBank::CashCountPosition.new
			@pos_card_terminal_position = CashBank::PosCardTerminalPosition.new
			defaults_daily_cash_closing
			flash[:warning] = "Se esta llevando el cierre del día <b class='red'>#{current_old_date_without_daily_cash_closing}</b>"
			render :action => :new_daily_cash_closing
	end


	def create_daily_cash_closing
		
		@daily_cash_closing = CashBank::DailyCashClosing.new(params[:cash_bank_daily_cash_closing])
		@cash_count_movement = CashBank::CashCountMovement.new(params[:cash_bank_cash_count_movement])
		@pos_card_terminal_movement = CashBank::PosCardTerminalMovement.new(params[:cash_bank_pos_card_terminal_movement])
		
		defaults_daily_cash_closing
		@success = @daily_cash_closing.valid?
		@success &= @cash_count_movement.valid?
		@success &= @pos_card_terminal_movement.valid?
		
		if @success
			@daily_cash_closing.save
			@cash_count_movement.cash_bank_daily_cash_closing = @daily_cash_closing
			@pos_card_terminal_movement.cash_bank_daily_cash_closing = @daily_cash_closing

			@cash_count_movement.save
			@pos_card_terminal_movement.save
			
			self.current_cash_count_position.each do |cash_count_position|
					cash_count_position.cash_bank_cash_count_movement = @cash_count_movement
					cash_count_position.save
			end
			self.current_pos_card_terminal_position.each do |pos_card_terminal_position|
					pos_card_terminal_position.cash_bank_pos_card_terminal_movement = @pos_card_terminal_movement
					pos_card_terminal_position.save
			end
			current_old_date_without_daily_cash_closing_clear
		end
	end

	def add_cash_count_position
		@daily_cash_closing = CashBank::DailyCashClosing.new
		defaults_daily_cash_closing
		@cash_count_position = CashBank::CashCountPosition.new(params[:cash_bank_cash_count_position])
		@success = @cash_count_position.valid?
		@cash_count_movement = CashBank::CashCountMovement.new
		if @success
			self.current_cash_count_position=params[:cash_bank_cash_count_position]
			@cash_count_positions = self.current_cash_count_position
			@cash_count_movement.total_amount_cash = @cash_count_positions.map(&:total_amount).to_sum
			@cash_count_movement.diference_amount_cash = @cash_count_movement.total_amount_cash - @daily_cash_closing.total_amount_cash
		end
	end

	def add_pos_card_terminal_position
		@daily_cash_closing = CashBank::DailyCashClosing.new
		defaults_daily_cash_closing
		@pos_card_terminal_position = CashBank::PosCardTerminalPosition.new(params[:cash_bank_pos_card_terminal_position])
		@success = @pos_card_terminal_position.valid?
		@pos_card_terminal_movement = CashBank::PosCardTerminalMovement.new
		if @success
			self.current_pos_card_terminal_position=params[:cash_bank_pos_card_terminal_position]
			@pos_card_terminal_positions = self.current_pos_card_terminal_position
			@pos_card_terminal_movement.total_amount_credit_debit = @pos_card_terminal_positions.map(&:total_amount).to_sum
			@pos_card_terminal_movement.diference_amount_credit_debit = @pos_card_terminal_movement.total_amount_credit_debit - ( @daily_cash_closing.total_amount_credit + @daily_cash_closing.total_amount_debit )
			@pos_card_terminals = CashBank::PosCardTerminal.all_not_included(@pos_card_terminal_positions.map(&:cash_bank_pos_card_terminal_id))
		end
		
	end

  def set_current_client
    self.current_client = params[:client_id]
  end

	def show_voucher_withholding_islr
		@invoice = Invoice.find(params[:invoice_id])
		respond_to do |format|
      format.html
      format.pdf do

				render :pdf                            => "voucher_withholding_islr_#{@invoice.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :orientation										 => 'Landscape',
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
							 :margin => {:top                => 25,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 }
			end
		end

	end


  protected

  def set_title
		if current_user.has_associate_cash?
			@title = "Caja Nº #{current_user.cash_bank_cash.fullname}"
		else
			@title = "Facturas"
		end
  end

  def defaults
    @payment_method_types = PaymentMethodType.all(:order => "name DESC")
		@cash_bank_pos_card_terminals = CashBank::PosCardTerminal.all
  end

	def defaults_daily_cash_closing
		@daily_cash_closing.responsible = current_user
		@daily_cash_closing.cash_bank_daily_cash_opening =  current_user.cash_bank_cash.open_for_today(current_old_date_without_daily_cash_closing)
		@daily_cash_closing.cash_bank_cash = current_user.cash_bank_cash

		total_transactions = IncomingInvoiceBilling.total_amount_today_fiscal_transactions(current_old_date_without_daily_cash_closing)
		@daily_cash_closing.date = total_transactions["today"]
		@daily_cash_closing.total_amount_sales_fiscal = total_transactions["all"]
		@daily_cash_closing.total_amount_cash_fiscal = total_transactions[PaymentMethodType::EFECTIVO]
		@daily_cash_closing.total_amount_credit_fiscal = total_transactions[PaymentMethodType::TARJETA_CREDITO]
		@daily_cash_closing.total_amount_debit_fiscal = total_transactions[PaymentMethodType::TARJETA_DEBITO]
		@daily_cash_closing.total_amount_check_fiscal = total_transactions[PaymentMethodType::CHEQUE]
		@daily_cash_closing.total_amount_deposit_fiscal = total_transactions[PaymentMethodType::TRANSFERENCIA_DEPOSITO]
		
		total_transactions = Budget.total_amount_today_transaction_with_advance_payments(current_old_date_without_daily_cash_closing)
		@daily_cash_closing.total_order_amount_with_advance_payment = total_transactions["all"]
		@daily_cash_closing.total_order_amount_cash_with_advance_payment = total_transactions[PaymentMethodType::EFECTIVO]
		@daily_cash_closing.total_order_amount_credit_with_advance_payment = total_transactions[PaymentMethodType::TARJETA_CREDITO]
		@daily_cash_closing.total_order_amount_debit_with_advance_payment = total_transactions[PaymentMethodType::TARJETA_DEBITO]
		@daily_cash_closing.total_order_amount_check_with_advance_payment = total_transactions[PaymentMethodType::CHEQUE]
		@daily_cash_closing.total_order_amount_deposit_with_advance_payment = total_transactions[PaymentMethodType::TRANSFERENCIA_DEPOSITO]

		total_transactions = IncomingInvoiceBilling.total_amount_today_fiscal_free_form(current_old_date_without_daily_cash_closing)
		@daily_cash_closing.total_amount_sales_free_form = total_transactions["all"]
		@daily_cash_closing.total_amount_cash_free_form = total_transactions[PaymentMethodType::EFECTIVO]
		@daily_cash_closing.total_amount_credit_free_form = total_transactions[PaymentMethodType::TARJETA_CREDITO]
		@daily_cash_closing.total_amount_debit_free_form = total_transactions[PaymentMethodType::TARJETA_DEBITO]
		@daily_cash_closing.total_amount_check_free_form = total_transactions[PaymentMethodType::CHEQUE]
		@daily_cash_closing.total_amount_deposit_free_form = total_transactions[PaymentMethodType::TRANSFERENCIA_DEPOSITO]

		@daily_cash_closing.total_amount_sales = @daily_cash_closing.total_amount_sales_free_form + @daily_cash_closing.total_amount_sales_fiscal
		@daily_cash_closing.total_amount_cash = @daily_cash_closing.total_amount_cash_free_form.to_f + @daily_cash_closing.total_amount_cash_fiscal.to_f
		@daily_cash_closing.total_amount_credit = @daily_cash_closing.total_amount_credit_free_form.to_f + @daily_cash_closing.total_amount_credit_fiscal.to_f
		
		@daily_cash_closing.total_amount_debit = @daily_cash_closing.total_amount_debit_free_form.to_f + @daily_cash_closing.total_amount_debit_fiscal.to_f
		@daily_cash_closing.total_amount_check = @daily_cash_closing.total_amount_check_free_form.to_f + @daily_cash_closing.total_amount_check_fiscal.to_f
		@daily_cash_closing.total_amount_deposit = @daily_cash_closing.total_amount_deposit_free_form.to_f + @daily_cash_closing.total_amount_deposit_fiscal.to_f

		@pos_card_terminals = CashBank::PosCardTerminal.all
	end






	def validate_responsible
		if not current_user.has_associate_cash?
			flash[:error] = "No posee caja asociada a su cuenta para registrar una factura"
			redirect_to backend_cpanel_home_index_url
		end
	end

	def validate_daily_cash_opening
		current_old_date_without_daily_cash_closing_clear
		cash_open = current_user.cash_bank_cash.without_daily_cash_closing?
		if cash_open
			flash[:error] = "No ha relizado el cierre respectivo del día #{cash_open.date} de la caja"
			self.current_old_date_without_daily_cash_closing=cash_open.date
			redirect_to new_daily_cash_closing_with_old_date_backend_invoices_url
		elsif current_user.cash_bank_cash.is_closed_for_today?
			flash[:error] = "La caja se encuentra cerrada por el día de hoy"
			redirect_to backend_invoices_url
		elsif not current_user.cash_bank_cash.is_opening_for_today?
			flash[:error] = "No ha iniciado apertura de caja.<br/>Haz click  <b><a href='#{new_daily_cash_opening_backend_invoices_url}'>aquí</a></b> para iniciar día"
			redirect_to backend_invoices_url
		end
	end

	def validate_if_can_new_invoice
		if current_user.cash_bank_cash.is_closed_on_sales_for_today?
			flash[:error] = "La caja se encuentra cerrada para la venta por el día de hoy"
			redirect_to backend_invoices_url
		end
	end

	def current_old_date_without_daily_cash_closing
		session[:old_date_without_daily_cash_closing]
	end

	def current_old_date_without_daily_cash_closing=(date)
		session[:old_date_without_daily_cash_closing] = date
	end

	def current_old_date_without_daily_cash_closing_clear
		session[:old_date_without_daily_cash_closing] = nil
	end

  def current_product_by_invoices=(product_by_invoice)
    session[:invoices_product_by_invoice] = [] if session[:invoices_product_by_invoice].nil?
    session[:invoices_product_by_invoice] << product_by_invoice
  end

  def remove_current_product_by_invoices(id_temporal)
    session[:invoices_product_by_invoice].each do |item|
    session[:invoices_product_by_invoice].delete(item) if item[:id_temporal].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_product_by_invoices
    product_by_invoices = []
    session[:invoices_product_by_invoice].each do |item|
      product_by_invoice = ProductByInvoice.new(item)
      product_by_invoice[:id_temporal] = item[:id_temporal]
      product_by_invoices << product_by_invoice
    end
    product_by_invoices
  end

  def current_product_by_invoices_clear
    session[:invoices_product_by_invoice] = []
  end

  def current_components_by_product_invoices=components_by_invoice
    session[:invoices_components_by_invoice] = [] if session[:invoices_components_by_invoice].nil?
    session[:invoices_components_by_invoice] << components_by_invoice
  end

  def remove_components_by_invoice(id_temporal)
    session[:invoices_components_by_invoice].each do |item|
      session[:invoices_components_by_invoice].delete(item) if item[id_temporal.to_sym].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_components_by_product_invoices
    components_by_invoice = {}
    session[:invoices_components_by_invoice].each do |item|
      item.each do |product_invoice_id,product_components|
        components_by_invoice[product_invoice_id.to_s.to_sym] = {}
        product_components.each do |product_component_id, product_components|
          components_by_invoice[product_invoice_id.to_s.to_sym][product_component_id.to_sym] = []
          product_components[:element_type].each do |element_type_name,element_type_id|
            product_component_by_invoice = ProductComponentByInvoice.new
            product_component_by_invoice.product_component_type_id = product_component_id
            product_component_by_invoice.element_id = element_type_id
            product_component_by_invoice.element_type = element_type_name

            components_by_invoice[product_invoice_id.to_s.to_sym][product_component_id.to_sym] << product_component_by_invoice.attributes
          end
        end
      end
    end
    components_by_invoice
  end

  def current_components_by_product_invoices_clear
    session[:invoices_components_by_invoice] = []
  end

  def current_accesories_by_product_invoices=accesories_by_invoice
    session[:invoices_accesories_product_by_invoice] = [] if session[:invoices_accesories_product_by_invoice].nil?
    session[:invoices_accesories_product_by_invoice] << accesories_by_invoice
  end

  def remove_accesories_by_invoice(id_temporal)
    session[:invoices_accesories_product_by_invoice].each do |item|
      session[:invoices_accesories_product_by_invoice].delete(item) if item[id_temporal.to_sym].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_accesories_by_product_invoices
    accesories_by_invoice = {}
    session[:invoices_accesories_product_by_invoice].each do |product_by_invoice|
      product_by_invoice.each do |product_invoice_id,accesories|
        accesories_by_invoice[product_invoice_id.to_s.to_sym] = []
        accesories.each do |accesory_id|
          accesory_componet_by_invoice = AccesoryComponentByInvoice.new
          accesory_componet_by_invoice.accessory_component_type_id = accesory_id
          accesories_by_invoice[product_invoice_id.to_s.to_sym] << accesory_componet_by_invoice
        end
      end
    end
    accesories_by_invoice
  end

  def current_accesories_by_product_invoices_clear
    session[:invoices_accesories_product_by_invoice] = []
  end

	def current_incoming_invoice_billings=incoming_invoice_billing
		session[:incoming_invoice_billing] = [] if session[:incoming_invoice_billing].nil?
		session[:incoming_invoice_billing] << incoming_invoice_billing
	end

	def current_incoming_invoice_billings
		incoming_invoice_billings = []
		session[:incoming_invoice_billing] = [] if session[:incoming_invoice_billing].nil?
    session[:incoming_invoice_billing].each do |item|
      incoming_invoice_billing = IncomingInvoiceBilling.new(item)
      incoming_invoice_billings << incoming_invoice_billing
    end
    incoming_invoice_billings
	end

	def current_incoming_invoice_billings_clear
		session[:incoming_invoice_billing] = []
	end

	def current_cash_count_position=cash_count_position
		session[:invoices_cash_count_positions] = [] if session[:invoices_cash_count_positions].nil?
		session[:invoices_cash_count_positions] << cash_count_position
	end

	def current_cash_count_position
		cash_count_positions = []
		session[:invoices_cash_count_positions] = [] if session[:invoices_cash_count_positions].nil?
    session[:invoices_cash_count_positions].each do |item|
      cash_count_positions << CashBank::CashCountPosition.new(item)
    end
    cash_count_positions
	end

	def current_cash_count_position_clear
		session[:invoices_cash_count_positions] = []
	end

	def current_pos_card_terminal_position=pos_card_terminal_position
		session[:invoices_pos_card_terminal_positions] = [] if session[:invoices_pos_card_terminal_positions].nil?
		session[:invoices_pos_card_terminal_positions] << pos_card_terminal_position
	end

	def current_pos_card_terminal_position
		pos_card_terminal_positions = []
		session[:invoices_pos_card_terminal_positions] = [] if session[:invoices_pos_card_terminal_positions].nil?
    session[:invoices_pos_card_terminal_positions].each do |item|
      pos_card_terminal_positions << CashBank::PosCardTerminalPosition.new(item)
    end
    pos_card_terminal_positions
	end

	def current_pos_card_terminal_position_clear
		session[:invoices_pos_card_terminal_positions] = []
	end
end

