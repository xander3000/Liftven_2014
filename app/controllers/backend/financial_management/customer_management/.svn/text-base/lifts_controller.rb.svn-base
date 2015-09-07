class Backend::FinancialManagement::CustomerManagement::LiftsController < Backend::FinancialManagement::CustomerManagement::BaseController

	def index

	end

	def new
		@client = Client.find(params[:client_id])
		@project = Crm::Project.find(params[:project_id])
		@lift = Crm::Projects::Lift.new
		@title = "Clientes / Detalle cliente #{@client.name} / Detalle proyecto #{@project.name} / Nuevo ascensor"
	end

	def create
		@client = Client.find(params[:client_id])
		@project = Crm::Project.find(params[:project_id])
		@lift = Crm::Projects::Lift.new(params[:crm_projects_lift])
		@lift.crm_project = @project
		@success = @lift.valid?
		if @success
			@lift.save
		end
	end

	def show
		@client = Client.find(params[:client_id])
		@project = Crm::Project.find(params[:id])
		@lifts = @project.crm_projects_lifts
		@title = "Clientes / Detalle cliente #{@client.name} / Detalle proyecto #{@project.name}"
	end

	def set_lift_model
		lift_category_type = Crm::Projects::LiftCategoryType.find(params[:crm_projects_lift][:crm_projects_lift_category_type_id])
		@lift_models = lift_category_type.crm_projects_lift_models
	end

	def set_phases_for_model
		@lift_model = Crm::Projects::LiftModel.find(params[:crm_projects_lift][:crm_projects_lift_model_id])
		@lift_manufacturing_phases = @lift_model.crm_projects_lift_manufacturing_phases
	end
end