class Backend::FinancialManagement::ReceivableAccountsController < Backend::FinancialManagement::BaseController

	def index
		@title = "Cuentas por cobrar"

			respond_to do |format|
			format.html do
				@receivable_accounts = Accounting::ReceivableAccount.all_not_cashed
			end
			format.pdf do
				@receivable_accounts = Accounting::ReceivableAccount.all_not_cashed_by_client
				render :pdf                            => "PayableAccounts",
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
end
  