class Backend::FinancialManagement::CustomerManagement::CallsController < Backend::FinancialManagement::CustomerManagement::BaseController
	def index
		@calls = Crm::Call.all
		@title = "CRM/Registro de llamadas"
	end

	def new
		@call = Crm::Call.new
		@title = "CRM/Registro de llamadas/nuevo"
		default
	end

	def create
		@call = Crm::Call.new(params[:crm_call])
		@success = @call.valid?
		if @success
			@call.save
		end
	end

	def show
		@call = Crm::Call.find(params[:id])
		@title = "CRM/Registro de llamadas/Detalle"
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end

	def edit
		@call = Crm::Call.find(params[:id])
		@title = "CRM/Registro de llamadas/Editar"
	end

	def update
		@call = Crm::Call.find(params[:id])
		@success = @call.update_attributes(params[:crm_call])
	end


	def autocomplete_for_relation
		render :json => eval(params[:related_to_type]).find_for_autocomplete("name",params[:term])
	end





	private

	def default
		@call.assigned_to = current_user
	  @reminders_popup = {"No recordar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		@email_all_invitees = {"No enviar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end


end
