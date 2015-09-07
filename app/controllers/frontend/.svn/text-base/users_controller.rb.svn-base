class Frontend::UsersController < Frontend::BaseController
  def index
     @user = User.new
     @user_session = UserSession.new
      redirect_to frontend_user_url(current_user) if logged_in?
  end


  def create
    @user = User.new(params[:user])
    @contact =  Contact.new(params[:contact])
    session_options = params[:user]
		@contact.validate_presence_of_email = true
    @contact.email = @user.login
    @contact.contact_types = [ContactType.cliente.id]
    @success = @user.valid?
    @success &= @contact.valid?
    if @success
      @user.save
      @contact.user = @user
      @contact.save
      @user_session = UserSession.new(session_options)
      @user_session.save
    end
  end

  def new
    @title = "Crea tu cuenta"
    @user = User.new
    @user_session = UserSession.new
    @contact =  Contact.new
  end

  def show
    @title = "Tu cuenta"
    @user = current_user
    @contact = @user.contact ? @user.contact : Contact.new
  end
end
