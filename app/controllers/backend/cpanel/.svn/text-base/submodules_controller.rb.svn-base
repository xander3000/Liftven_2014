class Backend::Cpanel::SubmodulesController < Backend::Cpanel::BaseController
	def index
     @title = "Seguridad / SubModulos"
		@submodules = ConfigPanel::Submodule.all
	end

	def new
    @title = "Seguridad / SubModulos / Nuevo"
		@submodule = ConfigPanel::Submodule.new
	end

	def create
		@submodule = ConfigPanel::Submodule.new(params[:config_panel_submodule])
		@success = @submodule.valid?
		if @success
			@submodule.save
		end
	end

	def show
    @title = "Seguridad / SubModulos / Detalle"
		@submodule = ConfigPanel::Submodule.find(params[:id])
	end

	def edit
    @title = "Seguridad / SubModulos / Editar"
		@submodule = ConfigPanel::Submodule.find(params[:id])
	end

	def update
		@submodule = ConfigPanel::Submodule.find(params[:id])
		@success = @submodule.update_attributes(params[:config_panel_submodule])
	end
end
