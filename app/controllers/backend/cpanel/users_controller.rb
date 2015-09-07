class Backend::Cpanel::UsersController < Backend::Cpanel::BaseController


	def index
		@title = "Usuarios"
		@users = User.all
	end

	def new
		@title = "Usuarios \ Nuevo usuario"
		@user = User.new
		@contact = Contact.new
	end

	def create
		@user = User.new(params[:user])
		@contact = Contact.new(params[:contact])

		@success =  @user.valid?
		@contact.valid?
    if @contact.exist?
      @contact = Contact.find_by_identification_document(@contact.identification_document)
      @success &=  @contact.update_attributes(params[:contact])
    else
      @success &=  @contact.valid?
			@contact.associated_with_user
    end
		if @contact.is_user?
			@success = false
			@contact.errors.add(:id,"ya esta asociado a un usuario")
		end


		if @success
			if @contact.exist?
				@contact.associante_and_create_contact_categories(ContactType.user,params[:user])
			end
			@contact.save
      @contact.associante_and_create_contact_categories(ContactType.user,params[:user])
      @contact.user.update_attributes(params[:user])
      @user = @contact.user
		end

	end

	def show
		@title = "Usuarios \ Detalle usuario"
		@user = User.find(params[:id])
		@contact = @user.contact

	end

	def edit
		@user = User.find(params[:id])
		@contact = @user.contact
	end

	def update
		@user = User.find(params[:id])
		@contact = @user.contact

		@success = @user.update_attributes(params[:user])
		@success &= @contact.update_attributes(params[:contact])
	end

	def destroy
		@user = User.find(params[:id])
	end
end
