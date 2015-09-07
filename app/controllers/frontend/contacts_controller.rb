class Frontend::ContactsController < Frontend::BaseController
  def create
    @user = User.last
    @contact = Contact.new(params[:contact])
    @success = @contact.valid?

    if @success
      @contact.user = @user
      @contact.contact_types = [ContactType.cliente.id]
      @contact.save
      
    end
  end

  def update
    @user = current_user
    @contact = Contact.find(params[:id])
    @success = @contact.update_attributes(params[:contact])
    if @success
    end
  end
end
