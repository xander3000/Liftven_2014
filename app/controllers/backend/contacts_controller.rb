class Backend::ContactsController < Backend::BaseController

  def index
    @contacts = Contact.all_by_letters
    @contact_types = [ContactType.first]
  end

  def select_list
    contact_type = ContactType.find_by_id(params[:contact_type_id])
    options = {}
		options[:filter_by_contact_type] = [contact_type.id] if not contact_type.nil?
    @contacts = Contact.all_by_letters(options)
    @contact_type_id = params[:contact_type_id]
  end

  def new
    @contact = Contact.new
		@contact.contact_types = []
		@user = User.new
    @client = Client.new
    @employee = Employee.new
    @supplier = Supplier.new
    @contact_types = [ContactType.first]
  end

  def create
		@objets = []
    @contact = Contact.new(params[:contact])
		@user = User.new(params[:user])
    @success = @contact.valid?
		@success &= @user.valid? if !@user.login.blank?

		@objets << @contact
		@objets << @user if !@user.login.blank?

    if @success
      @contact.save
			if !@user.login.blank?
				@user.contact = @contact
				@user.save
			end
      @contact.client.update_attributes(params[:client]) if @contact.is_client?
      @contact.employee.update_attributes(params[:employee]) if @contact.is_employee?
      @contact.supplier.update_attributes(params[:supplier]) if @contact.is_supplier?
      @contact.reload
			@contact_types = @contact.contact_types

    end
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def edit
    @contact = Contact.find(params[:id])
		@user = @contact.has_user? ? @contact.user : @user = User.new
    @client = @contact.client || Client.new
    @employee = @contact.employee ||  Employee.new
    @supplier = @contact.supplier ||  Supplier.new
    @contact_types = [ContactType.first]
  end

  def update
		@objets = []
    @contact = Contact.find(params[:id])
		@user = User.new(params[:user])
    @success = @contact.update_attributes(params[:contact])

		if @contact.has_user?
			@user = @contact.user
			@success &= @user.update_attributes(params[:user])
		elsif !@user.login.blank?
			@success &= @user.valid?
		end
		@objets << @contact
		@objets << @user if !@user.login.blank? or  @contact.has_user?


    if @success
			if !@user.login.blank?
				@user.contact = @contact
				@user.save
			end
      @contact.client.update_attributes(params[:client]) if @contact.is_client?
      @contact.employee.update_attributes(params[:employee]) if @contact.is_employee?
      @contact.supplier.update_attributes(params[:supplier]) if @contact.is_supplier?
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.update_attribute(:active, false)
    redirect_to backend_contacts_url
  end

  def autocomplete_by_client_name
    result = Contact.find_by_client_autocomplete("fullname",params[:term])
    render :json => result
  end

  def autocomplete_by_client_identification
    term = params[:term].delete("_")
    result = Contact.find_by_client_autocomplete("identification_document",term)
    render :json => result
  end

	def autocomplete_by_supplier_name 
    result = Contact.find_by_supplier_autocomplete("fullname",params[:term])
    render :json => result
  end

	def autocomplete_by_contact_name
    result = Contact.find_by_contact_autocomplete("fullname",params[:term])
    render :json => result
  end

  protected

  def set_title
    @title = "Contactos"
  end
end
