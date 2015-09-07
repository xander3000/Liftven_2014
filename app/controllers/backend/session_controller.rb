class Backend::SessionController < Backend::BaseController
  layout "backend/session"
  helper_method :validate_qaptcha?
  #after_filter :set_lockdown_values, :only => :create


  def new
		reset_session_values if logged_in?
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Bienvenido #{@user_session.user.name}!!"
      redirect_to backend_cpanel_home_index_url
    else
      flash[:error] = "La información de nombre de usuario o contraseña introducida no es correcta"
      render :action => :new
    end
  end

	def show
		@title = "Perfiles / Ver perfil"
		@user = current_user
		@contact = @user.contact
		render :layout => "backend/application"
	end

	def update_user
		@title = "Perfiles / Ver perfil"
		@user = current_user
		@contact = @user.contact
		@user.update_attributes(params[:user])
		@contact.update_attributes(params[:contact])
		redirect_to backend_session_url(current_user)
	end

  def destroy
    flash[:notice] = "Hasta luego #{current_user.name}!!"
    reset_session_values
		
		#TODO: CAMBIAR LOCKDOWN


    redirect_to new_backend_session_url
  end

  def qaptcha
    session[:qaptcha] = true
    render :text => "{\"error\":false}"
  end


  private

  def set_qaptcha
    session[:qaptcha] = false
  end

  def validate_qaptcha?
     false 
  end

  def set_lockdown_values
#    if user = @user_session.user
#      add_lockdown_session_values(user)
#    end
  end
end
