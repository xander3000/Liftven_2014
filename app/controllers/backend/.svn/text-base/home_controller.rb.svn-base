class Backend::HomeController < Backend::BaseController

  def index
		@states =  State.all_actives_apply_to_orders_with_presence
    @technicians_by_order_status = User.find_all_by_active_order_status(@states)
    @technicians_by_states = User.find_all_by_active_order_states(@states)

  end
end
