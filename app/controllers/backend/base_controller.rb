class Backend::BaseController < ApplicationController
  
	layout "backend/application_cpanel"
	#before_filter :validate_autorizations
	before_filter :validate_session#,:except => [:index]
	before_filter :set_title
  skip_before_filter :validate_autorizations,:only => :document_identification_lookup_seniat
	#before_filter :render_topnav_menunav

	def document_identification_lookup_seniat
		document = params[:doc]
		render :json => document_identification_lookup(document)
	end

  protected

#	def render_topnav_menunav
#
#	end
#  

  def current_client=(current_client)
    session[:current_client_id] = current_client
  end

  def current_client
    Client.find(session[:current_client_id]) if session[:current_client_id]
  end

  def current_client_clear
    session[:current_client_id] = nil
  end

	def validate_session
			@current_action = params[:action]
			@current_controller = params[:controller]
			@current_module = "#{@current_controller.camelize}Controller"
			if !logged_in?
				if !((@current_action.eql?("new") or @current_action.eql?("create")) and @current_module.eql?("Backend::SessionController"))
					flash[:error] = "Su sesión ha expirado..."
					redirect_to new_backend_session_url
				end
			end
			
	end


  def validate_autorizations
    @current_action = params[:action]
    @current_controller = params[:controller]
    @current_module = "#{@current_controller.camelize}Controller"
		

		logger.info "*******VALIDATE_AUTORIZATIONS*******"

		logger.info "\t@current_action: #{@current_action}"
		logger.info "\t@current_controller: #{@current_controller}"
		logger.info "\t@current_module: #{@current_module}"
		logger.info "\trequest.xhr?: #{request.xhr?}"
		logger.info "\trequest.get?: #{request.get?}"
		logger.info  "\trequest.referrer: #{request.referrer}"
		logger.info "************************************"

		p "*******VALIDATE_AUTORIZATIONS*******"
		
		p "\t@current_action: #{@current_action}"
		p "\t@current_controller: #{@current_controller}"
		p "\t@current_module: #{@current_module}"
		p "\trequest.xhr?: #{request.xhr?}"
		p "\trequest.get?: #{request.get?}"
		p "\trequest.referrer: #{request.referrer}"
		p "************************************"
		if logged_in?
				if !current_user.is_administrator?
					if !current_user.has_action_for_controller_by_role?(@current_module,@current_action)
						 @errors = "No posee permiso para acción [#{@current_module}/<b><i>#{@current_action}</i></b>]"
						 response.status = 401
								if request.xhr?
										if request.get?
											render :status => 401,:text => @errors
										else
											render :update do |page|
													page.show_flash_message_error(@errors)
											end
										end
								else
									if @current_action.eql?("new") and @current_module.eql?("Backend::SessionController")

									else
										flash[:error] = @errors
										redirect_to request.referrer
									end

								end
					 end
				end
		end
  end
	
end
