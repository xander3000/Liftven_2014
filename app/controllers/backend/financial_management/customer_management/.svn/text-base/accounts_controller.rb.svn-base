class Backend::FinancialManagement::CustomerManagement::AccountsController < Backend::FinancialManagement::CustomerManagement::BaseController

	def index
		@accounts = Crm::Account.all
		@title = "CRM/Cuentas"
	end

	def new
		@account = Crm::Account.new
		@title = "CRM/Cuentas/nuevo"
		default
	end

	def create
		@account = Crm::Account.new(params[:crm_account])
		@success = @account.valid?
		if @success
			@account.save
		end
	end

	def show
		@account = Crm::Account.find(params[:id])
		@title = "CRM/Cuentas/Detalle"
	end

	def edit
		@account = Crm::Account.find(params[:id])
		@title = "CRM/Cuentas/Editar"
	end

	def update
		@account = Crm::Account.find(params[:id])
		@success = @account.update_attributes(params[:crm_account])
	end

	def default
		@account.assigned_to = current_user
	end
end
