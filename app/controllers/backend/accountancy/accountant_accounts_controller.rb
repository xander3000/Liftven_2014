class Backend::Accountancy::AccountantAccountsController < Backend::Accountancy::BaseController

	def new
		@accountant_account = Accounting::AccountantAccount.new
		@accountant_account.parent_account = Accounting::AccountantAccount.find_by_id(params[:parent_account_id])

		if @accountant_account.parent_account.nil?
			@accountant_account.parent_account_id = 0
			@accountant_account.parent_account_code = 0
		else
			@accountant_account.parent_account_code = @accountant_account.parent_account.code
			@accountant_account.code = @accountant_account.parent_account.code
		end
		default
	end

	def create
		@accountant_account = Accounting::AccountantAccount.new(params[:accounting_accountant_account])
		@success = @accountant_account.valid?
		if @success
			@accountant_account.save
		end

	end

	def show_children
		@accountant_account = Accounting::AccountantAccount.find(params[:accountant_account_id])
	end

	def movements_by_criterion
		
	end

	def process_movements_by_criterion
		@transaction_movement_accounting_concepts = Accounting::TransactionMovementAccountingConcept.find_by_criterion(params[:accountant_accounts])
		@accountant_account = Accounting::AccountantAccount.find_by_id(params[:accountant_accounts][:accountant_account_id])
		@date_from = params[:accountant_accounts][:date_from]
		@date_to = params[:accountant_accounts][:date_to]
					render :pdf                            => "MayorAnalitico",
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
	
	protected

	def default
		@accountant_account.currency_type = CurrencyType.default
		@accountant_account.open_date  = Time.now.to_date
	end
end
