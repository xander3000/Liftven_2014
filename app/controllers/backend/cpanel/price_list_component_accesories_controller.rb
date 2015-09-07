class Backend::Cpanel::PriceListComponentAccesoriesController < Backend::Cpanel::BaseController
	def index
		@price_list_component_accesories = PriceListComponentAccesory.all
	end

	def show

	end

	def new

	end

	def create

	end

	def edit
		@price_list_component_accesory = PriceListComponentAccesory.find(params[:id])
	end

	def update
		price_list_component_accesory = PriceListComponentAccesory.find(params[:id])
		price_list_component_accesory.update_attributes(params[:price_list_component_accesory])
	end

	def set_title
    @title = "Lista de Precio por componentes"
  end
end
