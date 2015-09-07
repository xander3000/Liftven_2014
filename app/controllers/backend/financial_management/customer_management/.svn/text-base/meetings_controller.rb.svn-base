class Backend::FinancialManagement::CustomerManagement::MeetingsController < Backend::FinancialManagement::CustomerManagement::BaseController

	def index
		@meetings = Crm::Meeting.all
		@title = "CRM/Registro de reuniones"
	end

	def new
		@meeting = Crm::Meeting.new
		@title = "CRM/Registro de reuniones/nuevo"
		default
	end

	def create
		@meeting = Crm::Meeting.new(params[:crm_meeting])
		@success = @meeting.valid?
		if @success
			@meeting.save
		end
	end

	def show
		@meeting = Crm::Meeting.find(params[:id])
		@title = "CRM/Registro de reuniones/Detalle"
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end

	def edit
		@meeting = Crm::Meeting.find(params[:id])
		@title = "CRM/Registro de reuniones/Editar"
	end

	def update
		@meeting = Crm::Meeting.find(params[:id])
		@success = @meeting.update_attributes(params[:crm_meeting])
	end


	def autocomplete_for_relation
		render :json => eval(params[:related_to_type]).find_for_autocomplete("name",params[:term])
	end





	private

	def default
		@meeting.assigned_to = current_user
	  @reminders_popup = {"No recordar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		@email_all_invitees = {"No enviar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end


end
