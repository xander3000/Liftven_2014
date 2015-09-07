class Frontend::DesignsController <  Frontend::BaseController
  before_filter :clear_current_session_wizard_design,:clear_current_session_wizard_step,:only => [:new]
  helper_method :current_session_wizard_step,:current_type_design,:current_category_design,:current_model_design, :current_session_wizard_design

  def new
    @digital_card_models = DigitalCardModel.all(:conditions => ["digital_card_type_id = ?",3])
    @product_by_budget = ProductByBudget.new
		self.current_session_wizard_design=timestamp.to_s
  end

  def wizard
    step_number = params[:step_number]
    render :partial => "#{controller_path}/form_step_#{step_number}"
  end

  def wizard_step
		#desing_temporal = params[:desing_temporal]
		#desing_temporal = {desing_temporal => {"step_#{params[:step_number]}" => {:value => params[:step_value],:key => params[:step_key]}} }   if params[:step_value]
    self.current_session_wizard_step={"step_#{params[:step_number]}" => {:value => params[:step_value],:key => params[:step_key]}}   if params[:step_value]
		#draggable-item-position
		#draggable-item-text
		#draggable-item-color
		#draggable-item-size
		#draggable-item-font
		#draggable-item-position_left
		#draggable-item-position_top
		render :inline => current_session_wizard_step.keys.join(",")
  end

	def form_step_1_categories
		custom_design_type = CustomDesignType.find_by_id(params[:custom_design_type_id])
		@custom_design_category_types = custom_design_type ? custom_design_type.custom_design_category_types : []
	end

  def new_2
    @product_by_budget = ProductByBudget.new

  end

  def select_digital_card
    @digital_card_model = DigitalCardModel.find(params[:digital_card_id])
  end

  def preview
    @labels = params[:label]
  end

  def create

    id_temporal = timestamp.to_s
    digital_card = DigitalCard.new(params[:digital_card])
    finished_product_category_type = FinishedProductCategoryType.find(params[:finished_product_category_type_id])
    digital_card_fields = []
    digital_card[:id_temporal] = id_temporal
    labels = params[:label]
    labels.keys.each do |label_key|
      digital_card_field = DigitalCardField.new(:name => label_key,:value => labels[label_key.to_sym])
      digital_card_field[:id_temporal] = id_temporal
      digital_card_fields << digital_card_field.attributes
    end
    current_session_design_set(id_temporal,params[:finished_product_category_type_id], params[:digital_card],digital_card_fields)
    redirect_to frontend_new_with_digital_card_budgets_url(id_temporal)
  end

  def set_type_design
    self.current_type_design=params[:type_design]
		self.current_category_design=params[:category_design]
    render :inline => true
  end

  def set_model_design
    self.current_model_design=params[:model_design]
    render :inline => true
  end

	def model_design_preview
		render :layout => "frontend/clear"
	end

  def model_design_preview_2
		render :layout => "frontend/clear"
	end

  protected

  def current_session_wizard_step

    session[:frontend_designs_wizard_step][current_session_wizard_design]
  end

  def current_session_wizard_step=(wizard_step)
    session[:frontend_designs_wizard_step][current_session_wizard_design] = session[:frontend_designs_wizard_step][current_session_wizard_design].merge(wizard_step)
  end

  def clear_current_session_wizard_step
    clear_current_type_design
    clear_model_design
    session[:frontend_designs_wizard_step] = {}
  end

	def current_session_wizard_design
		 session[:frontend_designs_wizard_design]
	end

	def current_session_wizard_design=(wizard_design)
    session[:frontend_designs_wizard_design] = wizard_design
		session[:frontend_designs_wizard_step][wizard_design] = {}
  end

  def clear_current_session_wizard_design
    session[:frontend_designs_wizard_design] = nil
  end

  private

  def current_type_design
    session[:frontend_type_design_selected]
  end

  def current_type_design=(frontend_type_design_selected)
    session[:frontend_type_design_selected] = frontend_type_design_selected
  end

  def clear_current_type_design
    session[:frontend_type_design_selected] = nil
		clear_current_category_design
  end

  def current_category_design
    session[:frontend_category_design_selected]
  end

  def current_category_design=(frontend_category_design_selected)
    session[:frontend_category_design_selected] = frontend_category_design_selected
  end

  def clear_current_category_design
    session[:frontend_category_design_selected] = nil
  end

  def current_model_design
    session[:frontend_model_design_selected]
  end

  def current_model_design=(frontend_type_design_selected)
    session[:frontend_model_design_selected] = frontend_type_design_selected
  end


  def clear_model_design
    session[:frontend_model_design_selected] = nil
  end

  def current_session_design_set(id_temporal,finished_product_category_type_id,digital_card,digital_card_fields)
    key = DigitalCard::SESSION_KEY_REFERENCE
    current_session_design_clear
    session[key] = {}
    session[key][id_temporal.to_sym] = {}
    session[key][id_temporal.to_sym][:finished_product_category_type_id] = finished_product_category_type_id
    session[key][id_temporal.to_sym][:digital_card] = digital_card
    session[key][id_temporal.to_sym][:digital_card_fields] = digital_card_fields
  end


end
