class Backend::Cpanel::FinishProductTypePricesController < Backend::Cpanel::BaseController
	def index
		@finish_product_types = FinishProductType.all
	end

	def show

	end

	def new

	end

	def create

	end

	def edit
		@finish_product_type = FinishProductType.find(params[:id])
	end

	def update
		finish_product_type = FinishProductType.find(params[:id])
		finish_product_type.update_attributes(params[:finish_product_type])
	end

	protected

	def set_title
    @title = "Tipo de acabados"
  end
end
