class Backend::Cashbank::BanksController < Backend::Cashbank::BaseController
	def index
		@banks = CashBank::Bank.all
		@title = "Bancos"
	end

	def new
		@title = "Bancos / Nuevo banco"
		@bank = CashBank::Bank.new
	end

	def create
		@bank = CashBank::Bank.new(params[:cash_bank_bank])
		@success = @bank.valid?
		if @success
			@bank.save
		end
	end

	def show
		@bank = CashBank::Bank.find(params[:id])
		@title = "Bancos / Detalle banco #{@bank.name}"
	end

	def update
		@bank = CashBank::Bank.find(params[:id])
		@success = @bank.update_attributes(params[:cash_bank_bank])
	end

	def set_format_print_check
		@title = "Bancos / Configuración formato de impresión de cheque"
		@bank = CashBank::Bank.find(params[:bank_id])
#		respond_to do |format|
#
#				format.html
#				format.pdf do
#					render :pdf                            => "FormatoIMpresionCheque",
#								 :disposition                    => 'attachment',
#								 #:file                           => "#{controller_path}/bank_statement.erb",
#								 :layout												 =>	'backend/contable_document.html.erb',
##								 :show_as_html                   =>  params[:debug].present?,
#								 :orientation                    => 'Portrait',
#								 :page_size												=> 'Letter',            # default A4
#								 :lowquality	=> true,
#								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
#																				},
#															:left => '2'
#															},
#								 :margin => {:top                => 13,
#														 :bottom             => 20,
#														 :right              => 2,
#														 :left               => 5
#													 }
#				end
#		end
	end

	def process_set_format_print_check
		
	end

	def bank_disponibility_accounts
		@cash_banks = CashBank::Bank.all
		render :pdf                            => "bank_disponibility_accounts",
								 :disposition                    => 'attachment',
								 #:file                           => "#{controller_path}/bank_statement.erb",
								 :layout												 =>	'backend/contable_document.html.erb',
#								 :show_as_html                   =>  params[:debug].present?,
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',            # default A4
								 :lowquality	=> true,
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

	def bank_accounts
		@bank = CashBank::Bank.find(params[:bank_id])
		@bank_accounts = @bank.cash_bank_bank_accounts
		@title = "Bancos / Detalle banco #{@bank.name}/ Cuentas bancarias"
	end
end
