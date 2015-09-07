class Backend::FinancialManagement::CustomerManagement::CallManagerRegistersController < Backend::FinancialManagement::CustomerManagement::BaseController
	def index

	end

	def new
		@client = Client.find(params[:client_id])
		@project = Crm::Project.find(params[:project_id])
		@call_manager_register = Crm::Projects::CallManagerRegister.new
		@phones = []
		contact = @client.contact
		@phones << contact.phone if contact.phone
		@phones << contact.cellphone if contact.cellphone
	end

	def create
		@client = Client.find(params[:client_id])
		@project = Crm::Project.find(params[:project_id])
		@call_manager_register = Crm::Projects::CallManagerRegister.new(params[:crm_projects_call_manager_register])
		@call_manager_register.crm_project = @project
		@success = @call_manager_register.valid?
		if @success
			@call_manager_register.save
		end
		@call_manager_registers = @project.crm_projects_call_manager_registers

	end
	
end
