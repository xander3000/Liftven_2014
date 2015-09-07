class Backend::MaterialManagement::MeasureUnitsController < Backend::MaterialManagement::BaseController
	def index

	end

	def new
		@measure_unit = Material::MeasureUnit.new
	end

	def create
		@measure_unit = Material::MeasureUnit.new(params[:material_measure_unit])
		@success = @measure_unit.valid?
		if @success
			@measure_unit.save
		end
	end

	def show

	end
end
