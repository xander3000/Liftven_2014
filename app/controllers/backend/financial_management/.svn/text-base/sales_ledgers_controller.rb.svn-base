class Backend::FinancialManagement::SalesLedgersController < Backend::FinancialManagement::BaseController
def index
		@title = "Libro de Ventas"
    @invoices = Invoice.all_group_by_month_year
  end

	def show
		@title = "Libro de Ventas / Detalle mes"
		@invoices = Invoice.all_by_month_year(params[:id])
		@month_date = params[:id]
    year,month = @month_date.split("-").map(&:to_i)
    @period = "01/#{month.to_code("02")}/#{year} AL #{Date.civil(year, month, -1).day}/#{month.to_code("02")}/#{year}"
		respond_to do |format|
					format.html
					format.pdf do
            @title = "LIBRO DE VENTAS DEL #{@period}"
						render :pdf                            => "SalesLedgers_#{@month_date}",
									 :disposition                    => 'attachment',
									 :layout												 =>	'backend/contable_document.html.erb',
									 :orientation                    => 'Landscape',
									 :page_size												=> 'Legal',

									 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document_with_fiscal_info.erb'
																					},
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

	def sales_by_criterion
		@finished_product_category_types = FinishedProductCategoryType.all
		@products = Product.all
	end

	def process_sales_by_criterion
		@sales = Invoice.all_by_criterion(params[:sale])
		
		@date_from = params[:sale][:date_from]
		@date_to = params[:sale][:date_to]
		render :pdf                            => "BancoMovements",
					 :disposition                    => 'attachment',
					 :layout												 =>	'backend/contable_document.html.erb',
					 :orientation                    => 'Landscape',
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
