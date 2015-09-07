class Backend::FinancialManagement::PayableAccountsController < Backend::FinancialManagement::BaseController
	def index
		@title = "Cuentas por pagar"
		
				respond_to do |format|

				format.html do
					@payable_accounts = Accounting::PayableAccount.all_not_cashed
				end
				format.pdf do
					@payable_accounts = Accounting::PayableAccount.all_not_cashed_by_tenderer
					render :pdf                            => "PayableAccounts",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',
								 :font_name												=> 'sans-serif',
								 :copies												=> 2,

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


	def payable_accounts_report_status
				options = {:cashed => false,:canceled => false}
				case params[:status].to_i
						when  1
							options = {:cashed => true,:canceled => false}
						when 2
							options = {:cashed => false,:canceled => true}
						when 3
							options = {:cashed => false,:canceled => false}
				end
			@payable_accounts = Accounting::PayableAccount.all_not_cashed_by_tenderer(options)
					render :pdf                            => "PayableAccounts",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',
								 :font_name												=> 'sans-serif',
								 :copies												=> 2,
								 :template											=> "#{controller_path}/index.erb",
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
