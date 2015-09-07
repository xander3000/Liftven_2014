class Backend::FinancialManagement::CustomerManagement::ContractsController < Backend::FinancialManagement::CustomerManagement::BaseController

	def index
		@contracts = Crm::Contract.all
		@title = "CRM/Contratos"
	end

	def new
		@contract = Crm::Contract.new
		@title = "CRM/Contratos/nuevo"
		default
	end

	def create
		@contract = Crm::Contract.new(params[:crm_contract])
		@success = @contract.valid?
		if @success
			@contract.save
		end
	end

	def show
		@contract = Crm::Contract.find(params[:id])
		@title = "CRM/Contratos/Detalle"
	end

	def edit
		@contract = Crm::Contract.find(params[:id])
		@title = "CRM/Contratos/Editar"
	end

	def update
		@contract = Crm::Contract.find(params[:id])
		@success = @contract.update_attributes(params[:crm_contract])
	end

	def default
		@contract.assigned_to = current_user
	end

end
