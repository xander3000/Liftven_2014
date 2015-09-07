class Backend::Cpanel::ModulesController < Backend::Cpanel::BaseController
	def index
    @title = "Seguridad / Módulos"
		@modules = ConfigPanel::Module.all
	end

	def new
    @title = "Seguridad / Módulos / Nuevo"
		@module = ConfigPanel::Module.new
	end

	def create
		@module = ConfigPanel::Module.new(params[:config_panel_module])
		@success = @module.valid?
		if @success
			@module.save
		end
	end

	def show
    @title = "Seguridad / Módulos / Detalle"
		@module = ConfigPanel::Module.find(params[:id])
	end

	def edit
    @title = "Seguridad / Módulos / Editar"
		@module = ConfigPanel::Module.find(params[:id])
	end

	def update
		@module = ConfigPanel::Module.find(params[:id])
		@success = @module.update_attributes(params[:config_panel_module])
	end
end
