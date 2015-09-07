class Backend::Cpanel::StateMatricesController < Backend::Cpanel::BaseController

  def index
    @states = State.all_actives_apply_to_orders
  end

  def add_state_matrices
    
    params[:state].keys.each do |state_id|
      state_from = State.find_by_id(state_id)
      state_from.destination_states.clear
      params[:state][state_id.to_sym].each do |state_id_to|
        state_to = State.find_by_id(state_id_to)
        state_from.destination_states << state_to
      end
    end
    
  end
end
