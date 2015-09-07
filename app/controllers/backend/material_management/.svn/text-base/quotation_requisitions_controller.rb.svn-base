class Backend::MaterialManagement::QuotationRequisitionsController < Backend::MaterialManagement::BaseController
helper_method :current_quotation_requisition_positions_objects

  
  def index
		@title = "Cotización de pedidos de compra"
    @quotation_requisitions = Material::QuotationRequisition.all
  end
  
	def new
		@title = "Cotización de pedidos de compra / Nueva cotización"
		@quotation_requisition = Material::QuotationRequisition.new
    default
    current_quotation_requisition_positions_clear
	end
	
	def create
		@quotation_requisition_positions_t = []
		@quotation_requisition = Material::QuotationRequisition.new(params[:material_quotation_requisition])
		default
    @success = @quotation_requisition.valid?
		@success_t = true
		current_quotation_requisition_positions_objects.each do |quotation_requisition_position|
			material_purchase_requisition_position = quotation_requisition_position.material_purchase_requisition_position
      quotation_requisition_position_t = Material::QuotationRequisitionPosition.new(params[:material_quotation_requisition_position][material_purchase_requisition_position.id.to_s])
      quotation_requisition_position_t.material_purchase_requisition_position = material_purchase_requisition_position
      @success_t &= quotation_requisition_position_t.valid?
			@quotation_requisition_positions_t <<  quotation_requisition_position_t if quotation_requisition_position_t.valid?
		end
		if !@success_t
			@quotation_requisition.errors.add(:material_quotation_requisition_position_positions,"existe incosistencia, revisar")
		end

		if @success
			@quotation_requisition.save
			@quotation_requisition_positions_t.each do |quotation_requisition_position|
				quotation_requisition_position.material_quotation_requisition = @quotation_requisition
				quotation_requisition_position.save
        quotation_requisition_position.set_status_type
			end
		end
		
	end

  def show
    @quotation_requisition = Material::QuotationRequisition.find(params[:id])
    @quotation_requisition_positions = @quotation_requisition.material_quotation_requisition_position_positions
    @title = "Cotización de pedidos de compra / Detalle Cotización #{@quotation_requisition.id.to_code}"
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "QuotationRequisition_#{@quotation_requisition.id.to_code}",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Landscape',
								 :page_size												=> 'Letter',

								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																				},
															:left => '2'
															},
								 :margin => {:top                => 13,
														 :bottom             => 20,
														 :right              => 2,
														 :left               => 5
													 }
				end
		end
  end
  
  def edit
     @quotation_requisition = Material::QuotationRequisition.find(params[:id])
     current_quotation_requisition_positions_clear
      quotation_requisition_position = Material::QuotationRequisitionPosition.new
      @quotation_requisition.material_quotation_requisition_position_positions.each do |purchase_requisition_position|
#          quotation_requisition_position.material_purchase_requisition_position = purchase_requisition_position.material_purchase_requisition_position
#          quotation_requisition_position.material_raw_material = purchase_requisition_position.material_raw_material
#          quotation_requisition_position.material_order_measure_unit = purchase_requisition_position.material_order_measure_unit
#          quotation_requisition_position.quantity = purchase_requisition_position.quantity
          self.current_quotation_requisition_positions=purchase_requisition_position.attributes
      end
      purchase_requisition = @quotation_requisition.material_purchase_requisition
      if purchase_requisition
        quotation_requisition_position = Material::QuotationRequisitionPosition.new
        purchase_requisition.approved.each do |purchase_requisition_position|

            quotation_requisition_position.material_purchase_requisition_position = purchase_requisition_position
            quotation_requisition_position.material_raw_material = purchase_requisition_position.material_raw_material
            quotation_requisition_position.material_order_measure_unit = purchase_requisition_position.material_order_measure_unit
            quotation_requisition_position.quantity = purchase_requisition_position.approved_quantity
            self.current_quotation_requisition_positions=quotation_requisition_position.attributes
        end
      end
    
    
     unless @quotation_requisition.can_edit?
       flash[:warning] = "Cotización cerrada"
       redirect_to backend_material_management_quotation_requisition_url(@quotation_requisition)
     end
      @title = "Cotización de pedidos de compra / Modificar Cotización #{@quotation_requisition.id.to_code}"
  end
  
  def update
    @quotation_requisition_positions_t = []
    @quotation_requisition = Material::QuotationRequisition.find(params[:id])
    @success = @quotation_requisition.update_attributes(params[:material_quotation_requisition])
    
    @success_t = true
		current_quotation_requisition_positions_objects.each do |quotation_requisition_position|
			material_purchase_requisition_position = quotation_requisition_position.material_purchase_requisition_position

			if material_purchase_requisition_position.material_quotation_requisition_position
				material_quotation_requisition_position = material_purchase_requisition_position.material_quotation_requisition_position
				@success_t = material_quotation_requisition_position.update_attributes(params[:material_quotation_requisition_position][material_purchase_requisition_position.id.to_s])
				if @success_t
					material_quotation_requisition_position.reload
					quotation_requisition_position_t = material_quotation_requisition_position
        end
			else
				quotation_requisition_position_t = Material::QuotationRequisitionPosition.new(params[:material_quotation_requisition_position][material_purchase_requisition_position.id.to_s])
				quotation_requisition_position_t.material_purchase_requisition_position = material_purchase_requisition_position
				@success_t &= quotation_requisition_position_t.valid?
			end
			@quotation_requisition_positions_t <<  quotation_requisition_position_t if quotation_requisition_position_t.valid?
		end
    if !@success_t
			@quotation_requisition.errors.add(:material_quotation_requisition_position_positions,"existe incosistencia, revisar")
    else
      @quotation_requisition_positions_t.each do |quotation_requisition_position|
				quotation_requisition_position.material_quotation_requisition = @quotation_requisition
				quotation_requisition_position.save
        quotation_requisition_position.set_status_type
			end
		end
    
    
    @quotation_requisition.set_to_complete
  end
  
  def get_purchase_requisition_positions
    @purchase_requisition = Material::PurchaseRequisition.find_by_id(params[:material_quotation_requisition][:material_purchase_requisition_id])
    current_quotation_requisition_positions_clear
    if @purchase_requisition
      quotation_requisition_position = Material::QuotationRequisitionPosition.new
      @purchase_requisition.approved.each do |purchase_requisition_position|
          quotation_requisition_position.material_purchase_requisition_position = purchase_requisition_position
          quotation_requisition_position.material_raw_material = purchase_requisition_position.material_raw_material
          quotation_requisition_position.material_order_measure_unit = purchase_requisition_position.material_order_measure_unit
          quotation_requisition_position.quantity = purchase_requisition_position.approved_quantity
          self.current_quotation_requisition_positions=quotation_requisition_position.attributes
      end
    end
  end
  
  
	def select_best_supplier
		@quotation_requisition = Material::QuotationRequisition.find(params[:quotation_requisition_id])
		unless @quotation_requisition.can_select_best_supplier?
       flash[:warning] = "Cotización licitada"
       redirect_to backend_material_management_quotation_requisition_url(@quotation_requisition)
     end
		current_quotation_requisition_positions_clear
		@quotation_requisition_positions = @quotation_requisition.material_quotation_requisition_position_positions
	end

	def select_best_supplier_process
		@quotation_requisition = Material::QuotationRequisition.find(params[:quotation_requisition_id])
		@quotation_requisition.material_quotation_requisition_position_positions.each do |quotation_requisition_position|
			material_purchase_requisition_position = quotation_requisition_position.material_purchase_requisition_position
			if material_purchase_requisition_position.material_quotation_requisition_position
				material_quotation_requisition_position = material_purchase_requisition_position.material_quotation_requisition_position
				material_quotation_requisition_position.update_attributes(params[:material_quotation_requisition_position][material_purchase_requisition_position.id.to_s])
				material_quotation_requisition_position.set_status_type
			end
		end
	end

	protected

	def current_quotation_requisition_positions_objects
		@quotation_requisition_positions = []
 	 self.current_quotation_requisition_positions.each do |quotation_requisition_position|

			@quotation_requisition_positions << Material::QuotationRequisitionPosition.new(quotation_requisition_position)
		end
		@quotation_requisition_positions
	end


	def current_quotation_requisition_positions=(quotation_requisition_positions)
		session[:quotation_requisition_positions] = (session[:quotation_requisition_positions].nil? ? [] : session[:quotation_requisition_positions])
		session[:quotation_requisition_positions] << quotation_requisition_positions
	end

	def current_quotation_requisition_positions
		session[:quotation_requisition_positions].nil? ? [] : session[:quotation_requisition_positions]
	end

	def current_quotation_requisition_positions_clear
		session[:quotation_requisition_positions] =  []
	end

	def default
    
		@quotation_requisition.create_by = current_user
		@quotation_requisition.posting_date = Time.now.to_date
    

	end
  
  def default_positions
    quotation_requisition_position = Material::QuotationRequisitionPosition.new
    Material::PurchaseRequisitionPosition.all_approved.each do |purchase_requisition_position|
          quotation_requisition_position.material_purchase_requisition_position = purchase_requisition_position
          quotation_requisition_position.material_raw_material = purchase_requisition_position.material_raw_material
          quotation_requisition_position.material_order_measure_unit = purchase_requisition_position.material_order_measure_unit
          quotation_requisition_position.quantity = purchase_requisition_position.approved_quantity
          quotation_requisition_position.material_quotation_requisition = @quotation_requisition
          self.current_quotation_requisition_positions=quotation_requisition_position.attributes
    end
    Material::QuotationRequisitionPosition.all_with_a_missing_supplier_or_qouted.each do |quotation_requisition_position_aux|
      self.current_quotation_requisition_positions=quotation_requisition_position_aux.attributes
    end
#    Material::QuotationRequisitionPosition.all_with_a_missing_supplier.each do |quotation_requisition_position_aux|
#      self.current_quotation_requisition_positions=quotation_requisition_position_aux.attributes
#    end
  end
end
