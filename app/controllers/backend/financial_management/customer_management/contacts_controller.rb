class Backend::FinancialManagement::CustomerManagement::ContactsController < Backend::FinancialManagement::CustomerManagement::BaseController
	def index
			@contacts = Crm::Contact.all
			@title = "CRM/Contactos"
		end

		def new
			@contact = Crm::Contact.new
			@title = "CRM/Contactos/nuevo"
			default
		end

		def create
			@contact = Crm::Contact.new(params[:crm_contact])
			@success = @contact.valid?
			if @success
				@contact.save
			end
		end

		def show
			@contact = Crm::Contact.find(params[:id])
			@title = "CRM/Contactos/Detalle"
		end

		def edit
			@contact = Crm::Contact.find(params[:id])
			@title = "CRM/Contactos/Editar"
		end

		def update
			@contact = Crm::Contact.find(params[:id])
			@success = @contact.update_attributes(params[:crm_contact])
		end

		def default
			@contact.assigned_to = current_user
		end
end
