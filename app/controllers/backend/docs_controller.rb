class Backend::DocsController < Backend::BaseController

	def index
		@case = Case.find(params[:case_id])
		@docs = @case.all_docs_by_category
	end
end
