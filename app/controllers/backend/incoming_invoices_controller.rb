class Backend::IncomingInvoicesController < Backend::BaseController
	helper_method :current_incoming_invoice_positions_objects

  def index
		@title = "Facturación / Cuentas por pagar"
    @incoming_invoices = IncomingInvoice.all_payables
  end

  def show
    @incoming_invoice = IncomingInvoice.find(params[:id])
		@incoming_invoice_positions = @incoming_invoice.incoming_invoice_positions
  end

  def detail
    @incoming_invoice = IncomingInvoice.find(params[:incoming_invoice_id])
		@incoming_invoice_positions = @incoming_invoice.incoming_invoice_positions
		@incoming_invoice_payment = IncomingInvoicePayment.new
		@incoming_invoice_payments = @incoming_invoice.incoming_invoice_payments
  end

	def add_payment
		@incoming_invoice = IncomingInvoice.find(params[:incoming_invoice_id])
		@incoming_invoice_payment = IncomingInvoicePayment.new(params[:incoming_invoice_payment])
		@incoming_invoice_payment.incoming_invoice = @incoming_invoice
		@success = @incoming_invoice_payment.valid?
		if @success
			@incoming_invoice_payment.incoming_invoice = @incoming_invoice
			@incoming_invoice_payment.save
		end
		@incoming_invoice.reload
	end

	def set_incoming_invoice_document
		@incoming_invoice_document_type = IncomingInvoiceDocumentType.find_by_id(params[:incoming_invoice][:incoming_invoice_document_type_id])
		self.current_incoming_invoice_positions_clear
	end

  def new
		current_incoming_invoice_positions_clear
    @incoming_invoice = IncomingInvoice.new
		@incoming_invoice.currency_type = CurrencyType.default
		default
  end

  def create
    @incoming_invoice = IncomingInvoice.new(params[:incoming_invoice])
		default
		@incoming_invoice.has_added_item_positions?(current_incoming_invoice_positions_objects)
		@success = @incoming_invoice.valid?

		if @success
			@incoming_invoice.save
			current_incoming_invoice_positions_objects.each do |current_incoming_invoice_position|
				current_incoming_invoice_position.incoming_invoice = @incoming_invoice
				current_incoming_invoice_position.save
			end
		end

  end

  def edit
    @incoming_invoice = IncomingInvoice.find(params[:id])
  end

  def update
    @incoming_invoice = IncomingInvoice.find(params[:id])
  end

	def add
		@incoming_invoice_position = IncomingInvoicePosition.new(params[:incoming_invoice_position])
		@success = @incoming_invoice_position.valid?
		if @success
			self.current_incoming_invoice_positions=params[:incoming_invoice_position]
		end
	end

	def autocomplete_by_document_number
		#result = eval(current_goods_movement_reason_type).find_by_autocomplete_term("id",params[:term].to_i)
		render :json => result
	end

	def confirm_purchase_order
		current_incoming_invoice_positions_clear
		@purcharse_order = PurchaseOrder.find_by_id(params[:purchase_order_id])
		if @purcharse_order
			@purcharse_order.purchase_order_positions.each do |purchase_order_position|
				attributes = purchase_order_position.attributes
				attributes.delete("id")
				attributes.delete("purchase_order_id")
				#attributes.delete("packing_material_id")
				attributes.delete("delivery_date")
				attributes["description"] = purchase_order_position.raw_material.name
				self.current_incoming_invoice_positions=attributes
			end

		end
	end
	

	def current_incoming_invoice_positions_objects
		@incoming_invoice_positions = []
		self.current_incoming_invoice_positions.each do |incoming_invoice_position|
			@incoming_invoice_positions << IncomingInvoicePosition.new(incoming_invoice_position)
		end
		@incoming_invoice_positions
	end

	def current_incoming_invoice_positions=(incoming_invoice_positions)
		session[:incoming_invoice_positions] = (session[:incoming_invoice_positions].nil? ? [] : session[:incoming_invoice_positions])
		session[:incoming_invoice_positions] << incoming_invoice_positions
	end

	def current_incoming_invoice_positions
		session[:incoming_invoice_positions].nil? ? [] : session[:incoming_invoice_positions]
	end

	def current_incoming_invoice_positions_clear
		session[:incoming_invoice_positions] = []
	end

	def default
		@incoming_invoice.create_by = current_user
		@incoming_invoice.posting_date = Time.now.to_date
		@incoming_invoice.tax = AppConfig.tax
	end

	def account_payable
		
	end

	protected

  def set_title
    @title = "Entrada de Factura"
  end
end
