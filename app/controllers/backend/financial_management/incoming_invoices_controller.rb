class Backend::FinancialManagement::IncomingInvoicesController < Backend::FinancialManagement::BaseController
helper_method :current_incoming_invoice_positions_objects,:current_incoming_invoice_taxes_objects

  def index
		@title = "Facturas de Compras"
    @incoming_invoices = AccountPayable::IncomingInvoice.all_payables
  end

  def show
		@title = "Facturas de Compras / Detalle de factura"
    @incoming_invoice = AccountPayable::IncomingInvoice.find(params[:id])
		@incoming_invoice_positions = @incoming_invoice.account_payable_incoming_invoice_positions
		@incoming_invoice_taxes = @incoming_invoice.account_payable_incoming_invoice_taxes
		@retentions = @incoming_invoice.account_payable_incoming_invoice_retentions
		respond_to do |format|

				format.html
				format.pdf do
					
					render :pdf                            => "IncomingInvoice_#{@incoming_invoice.id.to_code}",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',

								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																				},
															:left => '2'
															},
								 :margin => {:top                => 13,
														 :bottom             => 20,
														 :right              => 2,
														 :left               => 5
													 }
				end
		end
  end

  def detail
    @incoming_invoice = AccountPayable::IncomingInvoice.find(params[:incoming_invoice_id])
		@incoming_invoice_positions = @incoming_invoice.account_payable_incoming_invoice_positions
		@incoming_invoice_taxes = @incoming_invoice.account_payable_incoming_invoice_taxes
		@incoming_invoice_payment = AccountPayable::IncomingInvoicePayment.new
		@incoming_invoice_payments = @incoming_invoice.account_payable_incoming_invoice_payments
  end

	def add_payment
		@incoming_invoice = AccountPayable::IncomingInvoice.find(params[:incoming_invoice_id])
		@incoming_invoice_payment = AccountPayable::IncomingInvoicePayment.new(params[:incoming_invoice_payment])
		@incoming_invoice_payment.account_payable_incoming_invoice = @incoming_invoice
		@success = @incoming_invoice_payment.valid?
		if @success
			@incoming_invoice_payment.account_payable_incoming_invoice = @incoming_invoice
			@incoming_invoice_payment.save
		end
		@incoming_invoice.reload
	end

	def set_incoming_invoice_document
		@incoming_invoice_document_type = AccountPayable::IncomingInvoiceDocumentType.find_by_id(params[:account_payable_incoming_invoice][:account_payable_incoming_invoice_document_type_id])
		self.current_incoming_invoice_positions_clear
	end

  def new
		@title = "Facturas de Compras / Nueva factura"
		current_incoming_invoice_positions_clear
    @incoming_invoice = AccountPayable::IncomingInvoice.new
		@incoming_invoice.currency_type = CurrencyType.default
    @incoming_invoice.purchase_ledger_period = (Time.now.to_date.to_s)[0,7]
		@incoming_invoice_retention =  AccountPayable::IncomingInvoiceRetention.new
		default

  end

  def create
    @incoming_invoice = AccountPayable::IncomingInvoice.new(params[:account_payable_incoming_invoice])
		default
		@success = @incoming_invoice.valid?
		@success &= @incoming_invoice.has_added_item_positions?(current_incoming_invoice_positions_objects)
		
		if @success
			@incoming_invoice.save
			current_incoming_invoice_positions_objects.each do |current_incoming_invoice_position|
				current_incoming_invoice_position.account_payable_incoming_invoice = @incoming_invoice
				current_incoming_invoice_position.save
			end
			@incoming_invoice.supplier.supplier_withholding_taxes.each do |supplier_withholding_tax|
				incoming_invoice_retention =  AccountPayable::IncomingInvoiceRetention.new
				incoming_invoice_retention.retained_amount = params[:account_payable_incoming_invoice_retention]["retained_amount_#{supplier_withholding_tax.id}".to_sym]
				incoming_invoice_retention.subject_retention_amount = params[:account_payable_incoming_invoice_retention]["subject_retention_amount_#{supplier_withholding_tax.id}".to_sym]
				incoming_invoice_retention.percentage = params[:account_payable_incoming_invoice_retention]["percentage_#{supplier_withholding_tax.id}".to_sym]
				incoming_invoice_retention.accounting_withholding_taxe_type = supplier_withholding_tax.accounting_withholding_taxe_type
				if incoming_invoice_retention.valid?
					incoming_invoice_retention.account_payable_incoming_invoice = @incoming_invoice
					incoming_invoice_retention.save
				end
			end
      @incoming_invoice.reload
			#After create
			@incoming_invoice.create_taxes
      @incoming_invoice.create_material_production_order
		end

  end

  def edit
    current_incoming_invoice_positions_clear
    @incoming_invoice = AccountPayable::IncomingInvoice.find(params[:id])
    @incoming_invoice_positions = @incoming_invoice.account_payable_incoming_invoice_positions
		@incoming_invoice_taxes = @incoming_invoice.account_payable_incoming_invoice_taxes
    @retentions = @incoming_invoice.account_payable_incoming_invoice_retentions
    @incoming_invoice_positions.each do |incoming_invoice_position|
      incoming_invoice_position[:id_temporal] = timestamp
      self.current_incoming_invoice_positions=incoming_invoice_position.attributes
    end
    @incoming_invoice_positions = current_incoming_invoice_positions_objects
  end

  def update
    @incoming_invoice = AccountPayable::IncomingInvoice.find(params[:id])
    @success = @incoming_invoice.update_attributes(params[:account_payable_incoming_invoice])
    if @success
      @incoming_invoice.account_payable_incoming_invoice_positions.map(&:destroy)
      current_incoming_invoice_positions_objects.each do |current_incoming_invoice_position|
				current_incoming_invoice_position.account_payable_incoming_invoice = @incoming_invoice
				current_incoming_invoice_position.save
			end
      @incoming_invoice.update_payable_account
      @incoming_invoice.set_value_balance
      @incoming_invoice.set_default_status_type
    end
  end

	def add
		@incoming_invoice = AccountPayable::IncomingInvoice.new
		@incoming_invoice_position = AccountPayable::IncomingInvoicePosition.new(params[:account_payable_incoming_invoice_position])
    @incoming_invoice_position[:id_temporal] = timestamp
		@success = @incoming_invoice_position.valid?
		if @success
			self.current_incoming_invoice_positions=params[:account_payable_incoming_invoice_position]
		end
		
    @incoming_invoice_positions = current_incoming_invoice_positions_objects
		@incoming_invoice_taxes = current_incoming_invoice_taxes_objects
    @taxable = @incoming_invoice_positions.map(&:taxable).sum.to_f.round(2)
		@sub_total = @incoming_invoice_positions.map(&:sub_total).sum.to_f.round(2)
    @total = @incoming_invoice_positions.map(&:total).sum.to_f.round(2)
		@incoming_invoice.sub_total_amount = @taxable
		
	end

  def remove_position
    @incoming_invoice = AccountPayable::IncomingInvoice.new
    remove_current_incoming_invoice_positions(params[:id_temporal])
    @incoming_invoice_positions = current_incoming_invoice_positions_objects
		@incoming_invoice_taxes = current_incoming_invoice_taxes_objects
    @taxable = @incoming_invoice_positions.map(&:taxable).sum.to_f.round(2)
		@sub_total = @incoming_invoice_positions.map(&:sub_total).sum.to_f.round(2)
    @total = @incoming_invoice_positions.map(&:total).sum.to_f.round(2)
		@incoming_invoice.sub_total_amount = @taxable
  end

	def autocomplete_by_document_number
		#result = eval(current_goods_movement_reason_type).find_by_autocomplete_term("id",params[:term].to_i)
		render :json => result
	end

	def confirm_purchase_order
		current_incoming_invoice_positions_clear
		@purcharse_order = Material::PurchaseOrder.find_by_id(params[:purchase_order_id])
    @success = true
		if @purcharse_order
      if @purcharse_order.account_payable_incoming_invoice
        @errors = ["Orden #{params[:purchase_order_id]} ya se encuentra contabilizado!"]
        @success = false
      else
        @purcharse_order.material_purchase_order_positions.each do |purchase_order_position|
          incoming_invoice_position = AccountPayable::IncomingInvoicePosition.new
          incoming_invoice_position.material_raw_material = purchase_order_position.material_raw_material
          incoming_invoice_position.material_order_measure_unit = purchase_order_position.material_order_measure_unit
          incoming_invoice_position.quantity = purchase_order_position.quantity
          incoming_invoice_position.sub_total = purchase_order_position.sub_total
          incoming_invoice_position.total = purchase_order_position.total
          self.current_incoming_invoice_positions=incoming_invoice_position.attributes
        end
      end
    else
			@errors = ["Orden #{params[:purchase_order_id]} no existe, por favor verificar!"]
      @success = false
		end
    
	end

	def search_supplier_withholding_taxes
		@supplier = Supplier.find(params[:supplier_id])
		@supplier_withholding_taxes = @supplier.supplier_withholding_taxes
		@incoming_invoice_retention =  AccountPayable::IncomingInvoiceRetention.new
	end

	def account_payable

	end


	def show_voucher_withholding
		@incoming_invoice = AccountPayable::IncomingInvoice.find(params[:incoming_invoice_id])
		@retentions = @incoming_invoice.account_payable_incoming_invoice_retentions

				render :pdf                            => "voucher_withholding_islr_#{@incoming_invoice.id}",
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
  
	def show_incoming_good_movement
		@incoming_invoice = AccountPayable::IncomingInvoice.find(params[:incoming_invoice_id])
	

				render :pdf                            => "incoming_good_movement_#{@incoming_invoice.id}",
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

	def report_resume
		@incoming_invoices = AccountPayable::IncomingInvoice.all
					render :pdf                            => "incoming_invoices",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',
								 :template											=> "#{controller_path}/reports/report_resume",
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '-1'
														},
							 :margin => {:top                => 15,
                           :bottom             => 25,
													 :right              => 5,
                           :left               => 5
 												 }
	end

	def report_islr_retentions
		@accounting_withholding_taxe_types = Accounting::WithholdingTaxeType.all(:order => "is_natural")
		render :template => "#{controller_path}/reports/report_islr_retentions"
	end

	def process_report_islr_retentions
    date_from = params[:incoming_invoice_retention][:date_from]
    date_to = params[:incoming_invoice_retention][:date_to]

		@incoming_invoice_retentions = AccountPayable::IncomingInvoiceRetention.all_by_date(date_from,date_to)
      respond_to do |format|

       format.pdf do
          render :pdf                            => "report_islr_retentions",
                       :disposition                    => 'attachment',
                       :layout												 =>	'backend/contable_document.html.erb',
                       :orientation                    => 'Landscape',
                       :page_size												=> 'Letter',
                       :template											=> "#{controller_path}/reports/process_report_islr_retentions",
                     :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
                                            },
                                  :left => '-1'
                                  },
                     :margin => {:top                => 15,
                                 :bottom             => 25,
                                 :right              => 5,
                                 :left               => 5
                               }
        end
        format.xml do
          year_to,month_to,day = date_to.split("-")
          if !File.exist?("#{RAILS_ROOT}/public/xml")
						system 'mkdir', '-p', "#{RAILS_ROOT}/public/xml"
					end
					file_name = "#{RAILS_ROOT}/public/xml/#{COMPANY_IDENTIFICATION_DOCUMENT}#{month_to}#{year_to}.xml"
					out_file = File.new(file_name, "w")


				  xml = Builder::XmlMarkup.new( :indent => 2, :target => out_file )
					xml.instruct! :xml, :encoding => "ISO-8859-1"
					xml.RelacionRetencionesISLR :RifAgente => COMPANY_IDENTIFICATION_DOCUMENT.gsub(/[\/-]/,''), :Periodo=> "#{year_to}#{month_to}" do |ri|
            Payroll::RegularPayrollCheck.all(:conditions => ["year = ? and month = ?",year_to,month_to]).each do |payroll_regular_payroll_check|
              payroll_regular_payroll_check.paid_employees.each do |employee|
                payroll_staff = employee.payroll_staff
                if !payroll_staff.rif.upcase.eql?("NP")
                ri.DetalleRetencion  do |dr|
                    dr.RifRetenido payroll_staff.rif.gsub(/[\/-]/,'')
                    dr.NumeroFactura "000"
                    dr.NumeroControl "000"
                    dr.FechaOperacion "#{Time.now.strftime("%d/%m/%Y")}"
                    dr.CodigoConcepto "001"
                    amount_base = 0
                    employee.all_payroll_payables_by_month_year(month_to,year_to).each do |payroll_regular_payroll_check|
                      amount_base += employee.islr_listed? ? payroll_regular_payroll_check.base_amount_by_concept_and_employee(Payroll::Concept::ISLR,employee).amount_base : payroll_regular_payroll_check.base_amount_by_concept_and_employee(Payroll::Concept::BASIC,employee).amount_allocated
                    end
                    dr.MontoOperacion amount_base
                    dr.PorcentajeRetencion "#{employee.islr_percentage}"
                  end
              end
                end
              end
              
              total_retained_amount = 0.0
              total_subject_retention_amount = 0.0

              AccountPayable::IncomingInvoiceRetention.all_by_date(date_from,date_to).each do |incoming_invoice_retention|
                if !incoming_invoice_retention.account_payable_incoming_invoice.actual_status.tag_name.eql?(AccountPayable::IncomingInvoiceStatusType::ANULADA)
                  total_retained_amount += incoming_invoice_retention.retained_amount.to_f
                  total_subject_retention_amount += incoming_invoice_retention.subject_retention_amount.to_f
                  account_payable_incoming_invoice = incoming_invoice_retention.account_payable_incoming_invoice
                  year_i,month_i,day_i = account_payable_incoming_invoice.invoice_date.split("-")
                              ri.DetalleRetencion  do |dr|
                                dr.RifRetenido account_payable_incoming_invoice.supplier.identification_document.gsub(/[\/-]/,'')
                                dr.NumeroFactura account_payable_incoming_invoice.reference
                                dr.NumeroControl account_payable_incoming_invoice.control_number
                                dr.FechaOperacion "#{day_i}/#{month_i}/#{year_i}"
                                dr.CodigoConcepto incoming_invoice_retention.accounting_withholding_taxe_type.code
                                dr.MontoOperacion incoming_invoice_retention.subject_retention_amount.to_f
                                dr.PorcentajeRetencion incoming_invoice_retention.accounting_withholding_taxe_type.percentage
                              end
                end

                end

					end

					out_file.close
					send_file file_name
        end
      end
  end
	def report_xlm_islr_retentions
		
	end

	def cancel
		@incoming_invoice = AccountPayable::IncomingInvoice.find(params[:incoming_invoice_id])
		@incoming_invoice.valid?
		@success = @incoming_invoice.can_cancel?
		if @success
			@incoming_invoice.cancel(current_user)
		end
	end

	protected

	def current_incoming_invoice_positions_objects
		@incoming_invoice_positions = []
		self.current_incoming_invoice_positions.each do |incoming_invoice_position|
			@incoming_invoice_positions << AccountPayable::IncomingInvoicePosition.new(incoming_invoice_position)
		end
		@incoming_invoice_positions
	end

	def current_incoming_invoice_taxes_objects
		taxes = {}
		@incoming_invoice_taxes = []
		current_incoming_invoice_positions_objects.each do |incoming_invoice_position|
			taxes[incoming_invoice_position.tax_id.to_s] = 0 if !taxes.has_key?(incoming_invoice_position.tax_id.to_s)
			taxes[incoming_invoice_position.tax_id.to_s] += incoming_invoice_position.taxable
		end
		taxes.each do |tax_id,taxable|
			tax_incoming_invoice = AccountPayable::IncomingInvoiceTax.new
			tax_incoming_invoice.tax_id = tax_id.to_i
			tax_incoming_invoice.taxable = taxable
			tax_incoming_invoice.tax_amount = tax_incoming_invoice.tax.amount*taxable/100
			tax_incoming_invoice.total_amount = tax_incoming_invoice.tax_amount + tax_incoming_invoice.taxable
			@incoming_invoice_taxes << tax_incoming_invoice
		end
		@incoming_invoice_taxes
	end

	def current_incoming_invoice_positions=(incoming_invoice_positions)
		session[:incoming_invoice_positions] = (session[:incoming_invoice_positions].nil? ? [] : session[:incoming_invoice_positions])
		session[:incoming_invoice_positions] << incoming_invoice_positions
	end

	def current_incoming_invoice_positions
		session[:incoming_invoice_positions].nil? ? [] : session[:incoming_invoice_positions]
	end

  def remove_current_incoming_invoice_positions(id_temporal)
    session[:incoming_invoice_positions].each do |item|
			session[:incoming_invoice_positions].delete(item) if item["id_temporal"].to_i.eql?(id_temporal.to_i)
    end
  end


	def current_incoming_invoice_positions_clear
		session[:incoming_invoice_positions] = []
	end

	def default
		@incoming_invoice.create_by = current_user
		@incoming_invoice.posting_date = Time.now.to_date
		@incoming_invoice.tax = @incoming_invoice.tax_exempt ? 0 : AppConfig.tax
	end


	

  def set_title
    @title = "Entrada de Factura"
  end
end
