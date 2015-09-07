class Backend::FinancialManagement::AdvancesController < Backend::FinancialManagement::BaseController
	def index

	end

	def new
		@client = Client.find(params[:client_id])
		@docs = @client.budgets_active
		@advance = Accounting::Advance.new
		@title = "Anticpo a clientes / nuevo anticipo"
		default
	end

	def create
		@client = Client.find(params[:client_id])
		@advance = Accounting::Advance.new(params[:accounting_advance])
		default
		@success = @advance.valid?
		if @success
			@advance.save
		end
	end

	def set_balance_from_doc
		@doc = eval(params[:advance_doc_type]).find_by_id(params[:accounting_advance][:doc_id])
	end


	protected

	def default
		@advance.client = @client
		@advance.user = current_user
		@advance.doc_type = "Budget"
	end
	
end
