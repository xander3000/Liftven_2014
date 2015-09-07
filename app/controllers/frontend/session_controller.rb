class Frontend::SessionController < Frontend::BaseController

  def create
    @user_session = UserSession.new(params[:user_session])
    @success = @user_session.valid?

    if @success
      @user_session.save
      flash[:notice] = "Bienvenido #{@user_session.user.name}!!"
    else
      flash[:error] = "La información de nombre de usuario o contraseña introducida no es correcta"
    end
  end


  def new
    @user_session = UserSession.new
  end
  
  def destroy
    flash[:notice] = "Hasta luego #{current_user.name}!!"
    current_user_session.destroy
    #TODO: matar sessiones
		##TODO: CAMBIAR LOCKDOWN
    #reset_lockdown_session
    redirect_to root_url
  end

  
end
