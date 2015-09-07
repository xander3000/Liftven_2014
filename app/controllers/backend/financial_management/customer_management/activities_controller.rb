class Backend::FinancialManagement::CustomerManagement::ActivitiesController < Backend::FinancialManagement::CustomerManagement::BaseController
	def index
		@activities = Crm::Activity.all
		@title = "CRM/Tareas"
	end

	def new
		@activity = Crm::Activity.new
		@title = "CRM/Tareas/nuevo"
		default
	end

	def create
		@activity = Crm::Activity.new(params[:crm_activity])
		@success = @activity.valid?
		if @success
			@activity.save
		end
	end

	def show
		@activity = Crm::Activity.find(params[:id])
		@title = "CRM/Tareas/Detalle"
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end

	def edit
		@activity = Crm::Activity.find(params[:id])
		@title = "CRM/Tareas/Editar"
	end

	def update
		@activity = Crm::Activity.find(params[:id])
		@success = @activity.update_attributes(params[:crm_activity])
	end


	def autocomplete_for_relation
		render :json => eval(params[:related_to_type]).find_for_autocomplete("name",params[:term])
	end





	private

	def default
		@activity.assigned_to = current_user
	  @reminders_popup = {"No recordar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		@email_all_invitees = {"No enviar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end
end
