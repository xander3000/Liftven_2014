class Backend::Cashbank::BankAccountsController < Backend::Cashbank::BaseController

	def index
		@bank_accounts = CashBank::BankAccount.all
		@title = "Cuentas Bancarias"
	end

	def new
		@title = "Cuentas Bancarias / Nueva cuenta"
		@bank_account = CashBank::BankAccount.new
	end

	def create
		@bank_account = CashBank::BankAccount.new(params[:cash_bank_bank_account])
		@success = @bank_account.valid?
		if @success
			@bank_account.save
		end
	end

	def show
		@bank_account = CashBank::BankAccount.find(params[:id])
		@title = "Cuentas Bancarias / Detalle de la cuenta #{@bank_account.name}"
	end

	def bank_movements
		@bank_account = CashBank::BankAccount.find(params[:bank_account_id])
		@bank_movements = @bank_account.cash_bank_bank_movements
		@title = "Cuentas Bancarias / Detalle de la cuenta #{@bank_account.name}/ Movimientos bancarios"
	end

	def checkbooks
		@bank_account = CashBank::BankAccount.find(params[:bank_account_id])
		@checkbooks = @bank_account.cash_bank_checkbooks
		@title = "Cuentas Bancarias / Detalle de la cuenta #{@bank_account.name}/ Chequereas asociadas"
	end
end
