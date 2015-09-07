class Backend::FinancialManagement::CustomerManagement::ProjectsController < Backend::FinancialManagement::CustomerManagement::BaseController

	def index

	end

	def new
		@client = Client.find(params[:client_id])
		@project = Crm::Project.new
		@title = "Clientes / Detalle cliente #{@client.name} / Nuevo proyecto"
	end

	def create
		@client = Client.find(params[:client_id])
		@project = Crm::Project.new(params[:crm_project])
		@project.client = @client
		@success = @project.valid?
		if @success
			@project.save
		end
	end

	def show
		@client = Client.find(params[:client_id])
		@project = Crm::Project.find(params[:id])
		@lifts = @project.crm_projects_lifts
		@call_manager_registers = @project.crm_projects_call_manager_registers
		
		@title = "Clientes / Detalle cliente #{@client.name} / Detalle proyecto #{@project.name}"
	end

end
