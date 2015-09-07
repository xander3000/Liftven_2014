class Backend::FinancialManagement::ClientsController < Backend::FinancialManagement::BaseController
	def index
		@title = "Clientes"
		@clients = Client.all#(:include => [:contact_category => :contact],:order => "identification_document ASC")
	end

	def new
		@title = "Clientes/ Nuevo cliente"
		@client = Client.new
		@contact = Contact.new
	end

	def create
		@client = Client.new(params[:client])
		@contact = Contact.new(params[:contact])
		
		@success =  @client.valid?
		@contact.valid?
    if @contact.exist?
      @contact = Contact.find_by_identification_document(@contact.identification_document)
      @success &=  @contact.update_attributes(params[:contact])
    else
      @success &=  @contact.valid?
			@contact.associated_with_client
    end
		if @contact.is_client?
			@success = false
			@contact.errors.add(:base,"ya esta asociado a un cliente")
		end


		if @success
			if @contact.exist?
				@contact.associante_and_create_contact_categories(ContactType.cliente)
			else
				@contact.save
			end
      @contact.client.update_attributes(params[:client])
      @client = @contact.client
		end
	end

	def show
		@client = Client.find(params[:id])
		@contact = @client.contact
		@budgets = @client.budgets
    @receivable_accounts = @client.accounting_paid_receivable_accounts
    @invoices = @client.invoices
    @credit_notes = @client.credit_notes
    @projects = @client.crm_projects
		@advances = @client.accounting_advances
    @title = "Clientes/ Detalle cliente #{@client.name}"
	end

	def edit
		@title = "Clientes/ Editar cliente"
		@client = Client.find(params[:id])
		@contact = @client.contact
	end

	def update
		@client = Client.find(params[:id])
		@success = @client.update_attributes(params[:Client])
    @success &= @client.contact.update_attributes(params[:contact])
	end
end
