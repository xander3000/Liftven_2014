class Backend::FinancialManagement::OutgoingInvoicesController < Backend::FinancialManagement::BaseController
  helper_method :current_client

	before_filter :defaults

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
    
#    params[:product_component_id].each do |product_component_id,product_components|
#      product_components[:id_temporal] = params[:product][:id_temporal]
#      product_components[:element_type].each do |element_type_name,element_type_id|
#        product_component_by_invoice = ProductComponentByInvoice.new
#        product_component_by_invoice[:id_temporal] = params[:product][:id_temporal]
#        product_component_by_invoice.product_component_type_id = product_component_id
#        product_component_by_invoice.element_id = element_type_id
#        product_component_by_invoice.element_type = element_type_name
#        if element_type_id.empty?
#          product_components[:element_type].delete(element_type_name)
#        else
#          @success &=  product_component_by_invoice.valid?
#        end
#
#      end
#    end if params[:product_component_id]
#
#    params[:accessories_ids].each do |accesory_id|
#      accesory_componet_by_invoice = AccesoryComponentByInvoice.new
#      accesory_componet_by_invoice[:id_temporal] = params[:product][:id_temporal]
#      accesory_componet_by_invoice.accessory_component_type_id = accesory_id
#      @success &=  accesory_componet_by_invoice.valid?
#    end if params[:accessories_ids]

    if @success
      
        self.current_product_by_invoices = params[:product]
#        self.current_components_by_product_invoices = {params[:product][:id_temporal] => params[:product_component_id]} if params[:product_component_id]
#        self.current_accesories_by_product_invoices= {params[:product][:id_temporal] => params[:accessories_ids]} if params[:accessories_ids]
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
			@title = "Factura de Venta"
  end

  def defaults
    @payment_method_types = PaymentMethodType.all(:order => "name DESC")
		@cash_bank_pos_card_terminals = CashBank::PosCardTerminal.all
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
