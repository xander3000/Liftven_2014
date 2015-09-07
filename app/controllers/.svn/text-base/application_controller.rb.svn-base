# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user,:logged_in?,:document_identification_lookup
  before_filter :defaults_only_for_app


  protected

  def defaults_only_for_app
      assets_struct = Struct.new(:CSS, :SCRIPTS, :IMAGES)
      assets = assets_struct.new("http://#{request.host_with_port}/assets/stylesheets",
                                 "http://#{request.host_with_port}/assets/scripts/lib",
                                 "http://#{request.host_with_port}/assets/images")

      config_struct = Struct.new(:SITE_HOST_WITH_PORT, :SITE_HOST, :SITE_PORT, :SITE_URL, :ASSETS)
      @@GLOBALS = @GLOBALS = config_struct.new(request.host_with_port,
                                               request.host,
                                               request.port,
                                               "http://#{request.host_with_port}",
                                               assets)


        logger.info "*** GLOBALS: #{@@GLOBALS} ***"
  end



  
  
  def set_title
    @title = controller_name.capitalize
  end


  def timestamp
    Time.now.to_i + rand(99)
  end

  def document_identification_lookup(document)
		result = {}
			url = "http://contribuyente.seniat.gob.ve/getContribuyente/getrif?rif=#{document}"

			response = Net::HTTP.get_response(URI.parse(url))
			result[:code] = response.code
			result[:success] = response.is_a?(Net::HTTPSuccess)
			if response.is_a?(Net::HTTPSuccess)
				xml_data = response.body
				xmldoc = REXML::Document.new(xml_data)
				#root = xmldoc.root
				#root.attributes['rif:numeroRif']
				result[:data] = {}
        
        result[:data][:document_fiscal_identification] = document
				result[:data][:fullname] = xmldoc.elements["rif:Rif/rif:Nombre"].text.split("(").first.strip
				result[:data][:retention_agent] = xmldoc.elements["rif:Rif/rif:AgenteRetencionIVA"].text
				result[:data][:taxpayer] = xmldoc.elements["rif:Rif/rif:ContribuyenteIVA"].text
				result[:data][:rate] = xmldoc.elements["rif:Rif/rif:Tasa"].text
			else
				result[:message_error] = response.body
			end
			return result
	 end



	protected
	def reset_session_values
		current_user_session.destroy
		session.clear
	end


  private


    def logged_in?
      !!current_user
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end




end
