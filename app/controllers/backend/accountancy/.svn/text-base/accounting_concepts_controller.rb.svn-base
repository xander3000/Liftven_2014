class Backend::Accountancy::AccountingConceptsController < Backend::Accountancy::BaseController

	def index
		@title = "Conceptos contables"
		@accounting_concepts = Accounting::AccountingConcept.all
	end

	def new
		@accounting_concept = Accounting::AccountingConcept.new
	end

	def create
		@accounting_concept = Accounting::AccountingConcept.new(params[:accounting_accounting_concept])
		@success = @accounting_concept.valid?
		if @success
			@accounting_concept.save
		end

	end

	def autocomplete_by_accountant_account
		result = Accounting::AccountantAccount.find_for_autocomplete("code",params[:term])
    render :json => result
	end
end
