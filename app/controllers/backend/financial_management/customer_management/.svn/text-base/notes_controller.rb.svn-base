class Backend::FinancialManagement::CustomerManagement::NotesController < Backend::FinancialManagement::CustomerManagement::BaseController
def index
		@notes = Crm::Note.all
		@title = "CRM/Notas"
	end

	def new
		@note = Crm::Note.new
		@title = "CRM/Notas/nuevo"
		default
	end

	def create
		@note = Crm::Note.new(params[:crm_note])
		@success = @note.valid?
		if @success
			@note.save
		end
	end

	def show
		@note = Crm::Note.find(params[:id])
		@title = "CRM/Notas/Detalle"
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end

	def edit
		@note = Crm::Note.find(params[:id])
		@title = "CRM/Notas/Editar"
	end

	def update
		@note = Crm::Note.find(params[:id])
		@success = @note.update_attributes(params[:crm_note])
	end


	def autocomplete_for_relation
		render :json => eval(params[:related_to_type]).find_for_autocomplete("name",params[:term])
	end





	private

	def default
		@note.assigned_to = current_user
	  @reminders_popup = {"No recordar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		@email_all_invitees = {"No enviar" => 0,"5 minutos" => 5,"20 minutos" => "20", "40 minutos" => 40, "Cada hora" => 60}
		related_to  = [Crm::Account,Crm::Contact,Crm::Contract,Crm::Lead,Crm::Meeting,Crm::Opportunity,Crm::Quote,Crm::Activity]
		@related_to = {}
		related_to.each do  |item|
			@related_to[item.model_humanize_name] = item.to_s
		end
	end

end
