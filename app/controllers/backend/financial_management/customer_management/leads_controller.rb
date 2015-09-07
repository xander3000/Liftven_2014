class Backend::FinancialManagement::CustomerManagement::LeadsController < Backend::FinancialManagement::CustomerManagement::BaseController
	def index
			@leads = Crm::Lead.all
			@title = "CRM/Contacto de negocios"
		end

		def new
			@lead = Crm::Lead.new
			@title = "CRM/Contacto de negocios/nuevo"
			default
		end

		def create
			@lead = Crm::Lead.new(params[:crm_lead])
			@success = @lead.valid?
			if @success
				@lead.save
			end
		end

		def show
			@lead = Crm::Lead.find(params[:id])
			@title = "CRM/Contacto de negocios/Detalle"
		end

		def edit
			@lead = Crm::Lead.find(params[:id])
			@title = "CRM/Contacto de negocios/Editar"
		end

		def update
			@lead = Crm::Lead.find(params[:id])
			@success = @lead.update_attributes(params[:crm_lead])
		end

		def default
			
		end
end
