class Frontend::BudgetsController < Frontend::BaseController
  helper_method :payment_method_selected
  def new
	current_components_by_product_budgets_clear
	current_budget_clear
	current_cart_clear
  payment_method_selected_clear

    defaults_for_new
  end

  def new_with_digital_card
    defaults_for_new
    id_temporal = params[:id_temporal]
    if current_session_design[id_temporal.to_sym].nil?
      redirect_to new_frontend_budget_url
      return
    end
    @finished_product_category_types = FinishedProductCategoryType.all(:conditions => {:id => [current_session_design[id_temporal.to_sym][:finished_product_category_type_id]]})
    if @finished_product_category_types.empty?
      redirect_to new_frontend_budget_url
      return
    end
    @product_by_budget[:id_temporal] = id_temporal
    render :action => "new"
  end

  def create
    @budget = Budget.new(payment_method_selected)
    if logged_in?
      if current_user.contact.is_client?
        @budget.client = current_user.contact.client
        
      end
			#TODO: Mejorar esta parte, ya se hizo en select_paymnety
			@budget.user = current_user
			@budget.delivery_time = "00:00 AM"
			@budget.responsible = "N/A"
    end
		
    product_by_budgets = self.current_cart
    components_by_product_budgets = self.current_components_by_product_budgets
    #accesories_by_product_budgets = self.current_accesories_by_product_budgets
		
    @success = @budget.valid?
    @success &= !product_by_budgets.empty?

    
    @budget.add_error_empty_products if product_by_budgets.empty?
    
    if @success
      @budget.save
      product_by_budgets.each do |product_by_budget|
        product_by_budget.budget = @budget
        product_by_budget.save
				components_by_product_budgets[product_by_budget[:id_temporal].to_s.to_sym].each do |product_component_type,product_components|
          product_components.each do |product_component|
            product_component_by_budget = ProductComponentByBudget.new(product_component)
            product_component_by_budget.product_by_budget = product_by_budget
            product_component_by_budget.save
          end
        end if components_by_product_budgets[product_by_budget[:id_temporal].to_s.to_sym]
        process_digital_card_referenced(product_by_budget)
      end
      @budget.set_values_sub_total_total
			options = {
          :current_user => current_user
        }
      @budget.generate_order(options)
      string = render_to_string :partial => "create_successfully"
			current_components_by_product_budgets_clear
			current_budget_clear
			current_cart_clear
			payment_method_selected_clear
      flash[:notice] = string
    end

  end

  def add_cart

    product_by_budget = params[:product_by_budget]
		product_by_budget[:id_temporal] = timestamp
		product_by_budget[:digital_card_id_temporal] = params[:digital_card_id_temporal]

		calculate
     if @success
			self.current_cart=(product_by_budget)
			self.current_components_by_product_budgets = {product_by_budget[:id_temporal] => params[:product_component_id]} if params[:product_component_id]
			#self.current_accesories_by_product_budgets= {product_by_budget[:id_temporal] => params[:accessories_ids]} if params[:accessories_ids]

       string = render_to_string :partial => "add_cart_successfully"
       flash[:notice] = string
     end
  end



  def find_products_by_category
    defaults_for_new
    @finished_product_category_type = FinishedProductCategoryType.find_by_id(params[:finished_product_category_type_id].to_i)
    @raw_materials = RawMaterial.find_all_by_finished_product_category_type(@finished_product_category_type)
    @products = @finished_product_category_type.products
  end


  def find_products_by_material
    raw_material = FinishedProductCategoryType.find_by_id(params[:finished_product][:raw_material])
    @products = Product.find_all_by_raw_material(raw_material) 
  end

  def find_product_components_by_product
    @product = Product.find_by_id(params[:product_by_budget][:product_id])
    @element_types = Product.elements_types
  end

	def custom_paper_size
    @product_component_type_id = params[:product_component_id].keys.first
    @page_size_type = PageSizeType.find_by_id(params[:product_component_id][@product_component_type_id]["element_type"]["PageSizeType"])
  end

  def custom_paper_type
    @product_component_type_id = params[:product_component_id].keys.first
    @paper_type = PaperType.find_by_id(params[:product_component_id][@product_component_type_id]["element_type"]["PaperType"])
    @paper_types = PaperType.all(:conditions => ["tag_name != ?",PaperType::OTRO]) if @paper_type and @paper_type.requiere_other_paper?
  end

  def custom_color_mode_type
    @product_component_type_id = params[:product_component_id].keys.first
    @color_mode_type = ColorModeType.find_by_id(params[:product_component_id][@product_component_type_id]["element_type"]["ColorModeType"])
  end

  def set_side_dimension
     @standard_measure = StandardMeasure.find_by_id(params[:standard_measure][:id].to_i)
  end

  def calculate
		@product = Product.find_by_id(params[:product_by_budget][:product_id])
		@product_by_budget = ProductByBudget.new(params[:product_by_budget])
    components = []
    params[:product_component_id].each do |product_component_id,elements|
      components << {:product_component_id => product_component_id}.merge(elements)
    end if params[:product_component_id]

    accesories_ids = params[:accessories_ids] ? params[:accessories_ids] : []
		options = params
		options[:product] = params[:product_by_budget]
		options[:to_hash] = true
    quantity = params[:product_by_budget][:quantity]
    result = @product.price_calculate(quantity,components,accesories_ids,params[:product_by_budget][:side_dimension_x],params[:product_by_budget][:side_dimension_y],options)

		@product_by_budget.valid?
		@success = result["code_response"].eql?("ok") ? true : false
    @product_by_budget.unit_price = result["unit_price"]
    @product_by_budget.total_price = result["total_price"]


#
#    @product_by_budget = ProductByBudget.new(params[:product_by_budget])
#    product = Product.find_by_id(@product_by_budget.product_id)
#    @product_by_budget.product = product
#    options = params[:product_by_budget].clone
#    options[:to_hash] = true
#    #TODO: Cambiar al usuario actual
#    if product and !@product_by_budget.quantity.to_i.zero?
#      result = product.find_price_by_client_list(@product_by_budget.quantity,nil,options)
#
#    end
#    @success = @product_by_budget.valid?

    if @success
      @unit_price = result["unit_price"]
      @total_price = result["total_price"]
      params[:product_by_budget][:unit_price] = result["unit_price"]
      params[:product_by_budget][:total_price] = result["total_price"]
    end
  end

  def remove_item

    current_cart_remove_item(params[:id_temporal])
  end

  def cart
    @title = "Carrito"
    @budget = Budget.new(payment_method_selected) if payment_method_selected
  end

  def select_payment
    @payment_methods = PaymentMethodType.find_all_online
    @order = Order.new
		@budget = Budget.new
		self.payment_method_selected = nil
  end

  def payment
		
    @order = Order.new(params[:order])
		@budget = Budget.new(params[:budget])
		@budget.advance_payment_process = true
		@budget.delivery_date = Time.now + 5
		#TODO Definir
		@budget.responsible = "N/A"
		@budget.delivery_time = "00:00 AM"

			if !current_user.nil?
				if current_user.contact.is_client?
						@order.client = current_user.contact.client
						@budget.client = current_user.contact.client
				end
				@order.user = current_user
				@budget.user = current_user
			end
			@success = @budget.valid?
			@success &= @order.valid?
			if @success
				self.current_budget=(@budget.attributes)
				self.payment_method_selected = @budget.attributes
			end
  end

  protected

  def payment_method_selected
    session[:payment_method_selected]
  end

  def payment_method_selected=(payment_method)
    session[:payment_method_selected] = payment_method
  end

  def payment_method_selected_clear
    session[:payment_method_selected] = nil
  end

  def defaults_for_new
    @product_by_budget = ProductByBudget.new
    @product = Product.new
    @finished_product_category_types = FinishedProductCategoryType.all
    @finished_product = FinishedProduct.new
    @standard_measure = StandardMeasure.new
  end

  def process_digital_card_referenced(product_by_budget)

		digital_card_id_temporal = product_by_budget.digital_card_id_temporal.to_s
    if digital_card_id_temporal
      digital_card = DigitalCard.new
      digital_card.product_by_budget = product_by_budget
			digital_card.image = session[:frontend_designs_wizard_step][digital_card_id_temporal]["step_2"][:value]
      digital_card.save
			#TODO: colocar esto en un metodo esta session
      digital_card_fields =  session[:frontend_designs_wizard_step][digital_card_id_temporal]["step_3"][:value]
			digital_card_fields =  CGI::parse(digital_card_fields)
			cont_field = 1
			digital_card_fields.each do |key|

				digital_card_field = DigitalCardField.new
				digital_card_field.input_text = digital_card_fields["draggable-item-text_#{cont_field}"].first
				digital_card_field.font_color = digital_card_fields["draggable-item-color_#{cont_field}"].first
				digital_card_field.font_family = digital_card_fields["draggable-item-font_#{cont_field}"].first
				digital_card_field.font_size = digital_card_fields["draggable-item-size_#{cont_field}"].first
				digital_card_field.position_left = digital_card_fields["draggable-item-position_left_#{cont_field}"].first
				digital_card_field.position_top = digital_card_fields["draggable-item-position_top_#{cont_field}"].first
				digital_card_field.digital_card_id = digital_card.id
				digital_card_field.save

				digital_card_fields.delete("draggable-item-color_#{cont_field}")
				digital_card_fields.delete("draggable-item-position_#{cont_field}")
				digital_card_fields.delete("draggable-item-position_left_#{cont_field}")
				digital_card_fields.delete("draggable-item-position_top_#{cont_field}")
				digital_card_fields.delete("draggable-item-font_#{cont_field}")
				digital_card_fields.delete("draggable-item-size_#{cont_field}")
				digital_card_fields.delete("draggable-item-text_#{cont_field}")

				cont_field+=1
			end

    end
  end

  def current_components_by_product_budgets=components_by_budget
    session[:frontend_budgets_components_by_budget] = [] if session[:frontend_budgets_components_by_budget].nil?
    session[:frontend_budgets_components_by_budget] << components_by_budget
  end

  def remove_components_by_budget(id_temporal)
    session[:frontend_budgets_components_by_budget].each do |item|
      session[:frontend_budgets_components_by_budget].delete(item) if item[id_temporal.to_sym].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_components_by_product_budgets
    components_by_budget = {}
    session[:frontend_budgets_components_by_budget].each do |item|
      item.each do |product_budget_id,product_components|
        components_by_budget[product_budget_id.to_s.to_sym] = {}
        product_components.each do |product_component_id, product_components|
          components_by_budget[product_budget_id.to_s.to_sym][product_component_id.to_sym] = []
          product_components[:element_type].each do |element_type_name,element_type_id|
            product_component_by_budget = ProductComponentByBudget.new
            product_component_by_budget.product_component_type_id = product_component_id
            product_component_by_budget.element_id = element_type_id
            product_component_by_budget.element_type = element_type_name
            components_by_budget[product_budget_id.to_s.to_sym][product_component_id.to_sym] << product_component_by_budget.attributes
          end
        end
      end
    end
    components_by_budget
  end

  def current_components_by_product_budgets_clear
    session[:frontend_budgets_components_by_budget] = []
  end


end
