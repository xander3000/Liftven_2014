class Backend::FinancialManagement::PurchaseLedgersController < Backend::FinancialManagement::BaseController
  def index
		@title = "Libro de Compras"
    @incoming_invoices = AccountPayable::IncomingInvoice.all_group_by_month_year

  end

	def show
		@title = "Libro de Compras / Detalle mes"
		result = AccountPayable::IncomingInvoice.all_by_month_year(params[:id])
		@incoming_invoices = result[:records]
		@taxes = result[:taxes]
		@with_exempts = result[:with_exempts]
		@month_date = params[:id]
    year,month = @month_date.split("-").map(&:to_i)
    @period = "01/#{month.to_code("02")}/#{year} AL #{Date.civil(year, month, -1).day}/#{month.to_code("02")}/#{year}"
		respond_to do |format|
					format.html
					format.pdf do
            @title = "LIBRO DE COMPRAS DEL  #{@period}"
						render :pdf                            => "PurchaseLedgers_#{@month_date}",
									 :disposition                    => 'attachment',
									 :layout												 =>	'backend/contable_document.html.erb',
									 :orientation                    => 'Landscape',
									 :page_size												=> 'Legal',

									 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document_with_fiscal_info.erb'},
																:left => '2'
																},
									 :margin => {:top                => 24,
															 :bottom             => 20,
															 :right              => 2,
															 :left               => 5
														 }
					end
		end
	end

  def search_by_date

  end

end
