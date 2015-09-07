class Backend::Cpanel::RawMaterialPriceDefinitionSetColorByComponentsController < Backend::Cpanel::BaseController
  	def index
      @raw_material_price_definition_set_color_by_components = RawMaterialPriceDefinitionSetColorByComponent.all(:order => "component_id ASC,raw_material_id ASC ")
	end

	def show

	end

	def new

	end

	def create

	end

	def edit
		@raw_material_price_definition_set_color_by_component = RawMaterialPriceDefinitionSetColorByComponent.find(params[:id])
	end

	def update
		raw_material_price_definition_set_color_by_component = RawMaterialPriceDefinitionSetColorByComponent.find(params[:id])
		raw_material_price_definition_set_color_by_component.update_attributes(params[:raw_material_price_definition_set_color_by_component])
	end

	def set_title
    @title = "Precios por Materia Prima y Componente (color)"
  end

end
