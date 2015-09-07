class Backend::ShortcutsController < Backend::BaseController
	before_filter :validate_responsible
	before_filter :validate_daily_cash_opening
	before_filter :validate_if_can_new_invoice


  def index
     @products = Product.all_for_shortcuts
     @invoice = Invoice.new
     @product_by_invoice = ProductByInvoice.new
  end

  def generate_invoice
		@invoice = Invoice.new(params[:invoice])
    @invoice.user = current_user
		@invoice.client = Contact.masive_user.client
		@invoice.currency_type = CurrencyType.default
		@invoice.invoice_printing_type_id = 2		
		@product_by_invoice = ProductByInvoice.new(params[:product])

		@invoice.sub_total = @product_by_invoice.total_price
		@invoice.total =@invoice.sub_total + @invoice.tax

		@success = @invoice.valid?
		@success &= @product_by_invoice.valid?

		@billing = IncomingInvoiceBilling.new
		@billing.payment_method_type = PaymentMethodType.default
		@billing.amount = @invoice.total
		@success &= @billing.valid?
		
		   

		if @success
			@invoice.save
			@product_by_invoice.invoice = @invoice
			@billing.invoice = @invoice

			@product_by_invoice.save
			@billing.save

			@invoice.print
		end


  end

  def set_title
    @title = "Acceso Rapido"
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


end
