class Backend::BudgetsController < Backend::BaseController

	before_filter :validate_daily_cash_opening,:only => [:show]

  def index
    respond_to do |format|
      format.html  do
        @budgets = Budget.all_paginate(:sortname => "budgets.created_at")
      end
      format.json  do
        render :json => Budget.all_to_json
      end
    end
    
  end

  def new
    @budget = Budget.new
    @client = Client.new
    @contact = Contact.new

    @element_types = Product.elements_types
    self.current_client_clear
    self.current_product_by_budgets_clear
    self.current_components_by_product_budgets_clear
    self.current_accesories_by_product_budgets_clear
  end

  def create
    @budget = Budget.new(params[:budget])
    @budget.user = current_user
    product_by_budgets = self.current_product_by_budgets
    components_by_product_budgets = self.current_components_by_product_budgets
    accesories_by_product_budgets = self.current_accesories_by_product_budgets
    @success = true
    unless current_client
      @contact = Contact.new(params[:contact])
			@contact.validate_presence_of_email = true
      @contact.associated_with_client
      valid = @contact.valid?
      @success &= valid
      if valid
        @contact.save
        @budget.client = @contact.client
      end
		else
			@contact = current_client.contact
			@success &= @contact.update_attributes(params[:contact])
    end
    @success &= @budget.valid?
    @success &= !product_by_budgets.empty?

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

        accesories_by_product_budgets[product_by_budget[:id_temporal].to_s.to_sym].each do |accesories_by_budget|
          accesories_by_budget.product_by_budget = product_by_budget
          accesories_by_budget.save
        end if accesories_by_product_budgets[product_by_budget[:id_temporal].to_s.to_sym]

      end 
      @budget.set_values_sub_total_total
			self.current_client_clear
			self.current_product_by_budgets_clear
			self.current_components_by_product_budgets_clear
			self.current_accesories_by_product_budgets_clear
    end
  end

  def show
    @budget = Budget.find(params[:id])
    @product_by_budgets = @budget.product_by_budgets
		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "budget_#{@budget.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :margin => {:top                => 18,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 },
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
								:footer => {:html => { :template => 'shared/backend/layouts/footer_contable_document.erb'
																			},
														:left => '2'
														}
			end
		end
  end

  def edit
    @budget = Budget.find(params[:id])
    @product_by_budgets = @budget.product_by_budgets
  end

	def search
    @budgets = Budget.search(params[:search_term])
  end

	def paginate
		@budgets = Budget.all_paginate(params)
	end

  def edit_quantity
    @budget = Budget.find(params[:budget_id])
    @contact = @budget.client.contact
    @product_by_budgets = @budget.product_by_budgets
  end

  def show_product_by_budget
    @budget = Budget.find(params[:budget_id])
    @product_by_budget = ProductByBudget.find(params[:product_by_budget_id])
  end

	def purchase_order
		@title = "Orden de compra"
		@budget = Budget.find(params[:budget_id])
		@product_by_budgets = @budget.product_by_budgets

						render :pdf                            => "orden_compra_#{@budget.order.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :margin => {:top                => 18,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 },
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
								:footer => {:html => { :template => 'shared/backend/layouts/footer_contable_document.erb'
																			},
														:left => '2'
														}

	end

  def update_quantity
    @budget = Budget.find(params[:budget_id])
    @product_by_budget = ProductByBudget.find(params[:product_by_budget_id])
    quantity = params[:product_by_budget][:quantity]
    client = @budget.client

    options = {
      :product_id => @product_by_budget.product_id,
      :quantity => quantity,
      :side_dimension_x => @product_by_budget.side_dimension_x,
      :side_dimension_y => @product_by_budget.side_dimension_y,
      :to_hash => true
    }
    result = @product_by_budget.product.find_price_by_client_list(quantity,client,options)
    @success = result["code_response"].eql?("ok")
    if @success
      @product_by_budget.update_attributes(:quantity => quantity,:unit_price => result["unit_price"],:total_price => result["total_price"])
    end

    @product = Product.find_by_id(params[:product][:product_id])
    components = []
    params[:product_component_id].each do |product_component_id,elements|
      components << {:product_component_id => product_component_id}.merge(elements)
    end if params[:product_component_id]

    accesories_ids = params[:accessories_ids] ? params[:accessories_ids] : []

    quantity = params[:product][:quantity]
    result = @product.price_calculate(quantity,components,accesories_ids,@product_by_budget.side_dimension_x,@product_by_budget.side_dimension_y,options)
    render :json => result
  end

  def add_product
    params[:product][:id_temporal] = timestamp
    product_by_budget = ProductByBudget.new(params[:product])
    @success = product_by_budget.valid?
    product_by_budget.errors.each { |e,r| puts "#{e}: #{r}" }
    params[:product_component_id].each do |product_component_id,product_components|
      product_components[:id_temporal] = params[:product][:id_temporal]
      product_components[:element_type].each do |element_type_name,element_type_id|
        product_component_by_budget = ProductComponentByBudget.new
        product_component_by_budget[:id_temporal] = params[:product][:id_temporal]
        product_component_by_budget.product_component_type_id = product_component_id
        product_component_by_budget.element_id = element_type_id
        product_component_by_budget.element_type = element_type_name
        if element_type_id.empty?
          product_components[:element_type].delete(element_type_name)
        else
          @success &=  product_component_by_budget.valid?
        end
        
      end 
    end if params[:product_component_id]

    params[:accessories_ids].each do |accesory_id|
      accesory_componet_by_budget = AccesoryComponentByBudget.new
      accesory_componet_by_budget[:id_temporal] = params[:product][:id_temporal]
      accesory_componet_by_budget.accessory_component_type_id = accesory_id
      @success &=  accesory_componet_by_budget.valid?
    end if params[:accessories_ids]

    if @success
       self.current_product_by_budgets = params[:product]
       self.current_components_by_product_budgets = {params[:product][:id_temporal] => params[:product_component_id]} if params[:product_component_id]
       self.current_accesories_by_product_budgets= {params[:product][:id_temporal] => params[:accessories_ids]} if params[:accessories_ids]
    end
    @product_by_budgets = self.current_product_by_budgets
    @components_by_budgets = self.current_components_by_product_budgets
    @accesories_by_budgets = self.current_accesories_by_product_budgets

  end

  def order_generate
    @budget = Budget.find(params[:budget_id])
    @success = @budget.update_attributes(params[:budget])
    if @success
      unless @budget.has_case?
        options = {
          :current_user => current_user
        }
        result = @budget.generate_order(options)
        @success = result[:success]
        if @success
           @budget.reload
          @order = @budget.order
          @budget.associate_case(@order.caso)
					@budget.create_invoice_for_advance_payment
        end
      else
        @order = @budget.order
        @success = true
      end
    end
  end

	def validate_daily_cash_opening
		@budget = Budget.find(params[:id])
		cash_open = current_user.cash_bank_cash ? current_user.cash_bank_cash.without_daily_cash_closing? : false
		if current_user.cash_bank_cash
		@can_order_generate = false
		if cash_open
			flash[:error] = "No ha relizado el cierre respectivo del día #{cash_open.date} de la caja"
			#redirect_to new_daily_cash_closing_with_old_date_backend_invoices_url
		elsif current_user.cash_bank_cash.is_closed_for_today?
			flash[:error] = "La caja se encuentra cerrada por el día de hoy"
			#redirect_to backend_invoice_url(@budget)
		elsif not current_user.cash_bank_cash.is_opening_for_today?
			flash[:error] = "No ha iniciado apertura de caja.<br/>Haz click  <b><a href='#{new_daily_cash_opening_backend_invoices_url}'>aquí</a></b> para iniciar día"
			#redirect_to backend_invoice_url(@budget)
		else
			flash[:notice] = "La caja se encuentra apertura para facturación"
			@can_order_generate = true
		end
end
	end


  def get_additional_payment_method_information
    @payment_method_type = PaymentMethodType.find(params[:budget][:payment_method_type_id])
  end

  def find_product_components_by_product
    @product = Product.find_by_id(params[:product_id])
    @element_types =Product.elements_types
  end

  def custom_paper_size
    @product_component_type = params[:product_component_type]
    @page_size_type = PageSizeType.find_by_id(params[:value])
  end

  def custom_paper_type
    @product_component_type_id = params[:product_component_type]
    @paper_type = PaperType.find_by_id(params[:value])
    @paper_types = PaperType.all(:conditions => ["tag_name != ?",PaperType::OTRO]) if @paper_type.requiere_other_paper?
  end

  def custom_color_mode_type
    @product_component_type_id = params[:product_component_type]
    @color_mode_type = ColorModeType.find_by_id(params[:value])
  end

  def remove_product
    self.remove_accesories_by_budget(params[:id_temporal])
    self.remove_current_product_by_budgets(params[:id_temporal])
    self.remove_components_by_budget(params[:id_temporal])
    @product_by_budgets = self.current_product_by_budgets
    @components_by_budgets = self.current_components_by_product_budgets
    @accesories_by_budgets = self.current_accesories_by_product_budgets
  end

  def add_discount
    @budget = Budget.new(params[:budget])
    @product_by_budgets = self.current_product_by_budgets
  end

  def set_current_client
    self.current_client = params[:contact_identification_document]
    render :text => self.current_client
  end

  def current_product_by_budgets=(product_by_budget)
    session[:budgets_product_by_budget] = [] if session[:budgets_product_by_budget].nil?
    session[:budgets_product_by_budget] << product_by_budget
  end

  def remove_current_product_by_budgets(id_temporal)
    session[:budgets_product_by_budget].each do |item|
    session[:budgets_product_by_budget].delete(item) if item[:id_temporal].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_product_by_budgets
    product_by_budgets = []
    session[:budgets_product_by_budget].each do |item|
      product_by_budget = ProductByBudget.new(item)
      product_by_budget[:id_temporal] = item[:id_temporal]
      product_by_budgets << product_by_budget
    end
    product_by_budgets
  end

  def current_product_by_budgets_clear
    session[:budgets_product_by_budget] = []
  end

  def current_components_by_product_budgets=components_by_budget
    session[:budgets_components_by_budget] = [] if session[:budgets_components_by_budget].nil?
    session[:budgets_components_by_budget] << components_by_budget
  end

  def remove_components_by_budget(id_temporal)
    session[:budgets_components_by_budget].each do |item|
      session[:budgets_components_by_budget].delete(item) if item[id_temporal.to_sym].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_components_by_product_budgets
    components_by_budget = {}
    session[:budgets_components_by_budget].each do |item|
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
    session[:budgets_components_by_budget] = []
  end

  def current_accesories_by_product_budgets=accesories_by_budget
    session[:budgets_accesories_product_by_budget] = [] if session[:budgets_accesories_product_by_budget].nil?
    session[:budgets_accesories_product_by_budget] << accesories_by_budget
  end

  def remove_accesories_by_budget(id_temporal)
    session[:budgets_accesories_product_by_budget].each do |item|
      session[:budgets_accesories_product_by_budget].delete(item) if item[id_temporal.to_sym].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_accesories_by_product_budgets
    accesories_by_budget = {}
    session[:budgets_accesories_product_by_budget].each do |product_by_budget|
      product_by_budget.each do |product_budget_id,accesories|
        accesories_by_budget[product_budget_id.to_s.to_sym] = []
        accesories.each do |accesory_id|
          accesory_componet_by_budget = AccesoryComponentByBudget.new
          accesory_componet_by_budget.accessory_component_type_id = accesory_id
          accesories_by_budget[product_budget_id.to_s.to_sym] << accesory_componet_by_budget
        end
      end
    end
    accesories_by_budget
  end

  def current_accesories_by_product_budgets_clear
    session[:budgets_accesories_product_by_budget] = []
  end

    protected

  def set_title
    @title = "Presupuesto"
  end

end
