class Backend::CasesController < Backend::BaseController

	def index
		respond_to do |format|
      format.html  do
        @cases = Case.all_by_user_and_states(current_user)
      end
      format.json  do
        render :json => Order.all_to_json
      end
    end
	end
end
