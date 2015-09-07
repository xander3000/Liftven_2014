class Backend::MaterialManagement::RawMaterialCategoriesController < Backend::MaterialManagement::BaseController
	def index

	end

	def new
		@raw_material_category = Material::RawMaterialCategory.new
	end

	def create
		@raw_material_category = Material::RawMaterialCategory.new(params[:material_raw_material_category])
		@success = @raw_material_category.valid?
		if @success
			@raw_material_category.save
		end
	end

	def show

	end
	
end
