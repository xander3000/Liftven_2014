class Backend::Cashbank::CheckOfferedsController < Backend::Cashbank::BaseController
	
	def index
		@check_offereds = CashBank::CheckOffered.all
		@title = "Cheque contabilizados"
	end


	def new
		@check_offered = CashBank::CheckOffered.new
		default
	end

	def create
		@check_offered = CashBank::CheckOffered.new(params[:cash_bank_check_offered])
		default
		@success = @check_offered.valid?
		if @success
			#@check_offered.save
			@check_offered.cancel
		end
	end

	def search_bank_account_by_bank
		bank = CashBank::Bank.find_by_id(params[:cash_bank_check_offered][:cash_bank_bank])
		@bank_acounts = []
		@bank_acounts = bank.cash_bank_bank_accounts if bank
	end

	def search_checkbook_by_bank_account
		bank_account = CashBank::BankAccount.find_by_id(params[:cash_bank_check_offered][:cash_bank_bank_account])
		@checkbooks = []
		@checkbooks = bank_account.cash_bank_checkbooks if bank_account
	end

	def default
		@check_offered.date = Time.now.to_date
		@check_offered.cash_bank_check_status_type = CashBank::CheckStatusType.find_by_tag_name("anulado")
		@check_offered.amount = 0
	end
end
