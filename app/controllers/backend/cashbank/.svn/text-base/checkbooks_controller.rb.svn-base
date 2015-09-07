class Backend::Cashbank::CheckbooksController < Backend::Cashbank::BaseController
  def index
    @checkbooks = CashBank::Checkbook.all
    @title = "Chequeras"
	end

	def new
		@checkbook = CashBank::Checkbook.new
	end

	def create
		@checkbook = CashBank::Checkbook.new(params[:cash_bank_checkbook])
		@success = @checkbook.valid?
		if @success
			@checkbook.save
		end
	end

  def check_offereds
    @checkbook = CashBank::Checkbook.find(params[:checkbook_id])
    @check_offereds = @checkbook.cash_bank_check_offereds
		@title = "Chequeras / Detalle de chequera #{@checkbook.cash_bank_bank_account.name} / Desglose de cheques"
  end

	def search_bank_account_by_bank
		@bank = CashBank::Bank.find_by_id(params[:cash_bank_checkbook][:cash_bank_bank])
		@bank_acounts = []
		@bank_acounts = @bank.cash_bank_bank_accounts if @bank
	end

end
