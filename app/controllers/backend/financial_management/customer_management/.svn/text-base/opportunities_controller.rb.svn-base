class Backend::FinancialManagement::CustomerManagement::OpportunitiesController < Backend::FinancialManagement::CustomerManagement::BaseController
	def index
		@opportunities = Crm::Opportunity.all
		@title = "CRM/Oportunidades"
	end

	def new
		@opportunity = Crm::Opportunity.new
		@title = "CRM/Oportunidades/nuevo"
		default
	end

	def create
		@opportunity = Crm::Opportunity.new(params[:crm_opportunity])
		@success = @opportunity.valid?
		if @success
			@opportunity.save
		end
	end

	def show
		@opportunity = Crm::Opportunity.find(params[:id])
		@title = "CRM/Oportunidades/Detalle"
	end

	def edit
		@opportunity = Crm::Opportunity.find(params[:id])
		@title = "CRM/Oportunidades/Editar"
	end

	def update
		@opportunity = Crm::Opportunity.find(params[:id])
		@success = @opportunity.update_attributes(params[:crm_opportunity])
	end

	def default
		@opportunity.assigned_to = current_user
	end
end
