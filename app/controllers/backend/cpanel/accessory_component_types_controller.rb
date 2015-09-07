class Backend::Cpanel::AccessoryComponentTypesController < Backend::Cpanel::BaseController
	def index
		@accessory_component_types = AccessoryComponentType.all
	end

	def show

	end

	def new

	end

	def create

	end

	def edit
		@accessory_component_type = AccessoryComponentType.find(params[:id])
	end

	def update
		accessory_component_type = AccessoryComponentType.find(params[:id])
		accessory_component_type.update_attributes(params[:accessory_component_type])
	end

	protected
	
	def set_title
    @title = "Tipo de accesorios"
  end

end
