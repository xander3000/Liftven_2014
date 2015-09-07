class Backend::MaterialManagement::PurchaseRequisitionsController < Backend::MaterialManagement::BaseController
helper_method :current_purchase_requisition_positions_objects

	def index
		@title = "Pedido de compra"
		@purchase_requisitions = Material::PurchaseRequisition.all_owner(current_user)
	end


	def new
		@title = "Pedido de compra / Nuevo pedido"
		@purchase_requisition = Material::PurchaseRequisition.new
		current_purchase_requisition_positions_clear
		default
	end

	def add
		@purchase_requisition_position = Material::PurchaseRequisitionPosition.new(params[:material_purchase_requisition_position])
		@success = @purchase_requisition_position.valid?
		if @success
			self.current_purchase_requisition_positions=params[:material_purchase_requisition_position]
		end
	end

  def create
    @purchase_requisition = Material::PurchaseRequisition.new(params[:material_purchase_requisition])
		default
		
		@success = @purchase_requisition.valid?
		@success &= @purchase_requisition.has_added_item_positions?(current_purchase_requisition_positions_objects)
		if @success
			@purchase_requisition.save
			current_purchase_requisition_positions_objects.each do |current_purchase_requisition_position|
				current_purchase_requisition_position.material_purchase_requisition = @purchase_requisition
				current_purchase_requisition_position.save
				current_purchase_requisition_position.set_quantity_values
			end
		end

  end


  def show
		@title = "Pedido de compra / Detalle del pedido"
    @purchase_requisition = Material::PurchaseRequisition.find(params[:id])
		@purchase_requisition_positions = @purchase_requisition.material_purchase_requisition_positions
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "ProductionOrder_#{@purchase_requisition.id.to_code}",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
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

	def verify
		@title = "Pedido de compra / Validar pedido"
    @purchase_requisition = Material::PurchaseRequisition.find(params[:purchase_requisition_id])
		@purchase_requisition_positions = @purchase_requisition.material_registered_purchase_requisition_positions
	end

	def verify_process
		@purchase_requisition = Material::PurchaseRequisition.find(params[:purchase_requisition_id])
		purchase_requisition_positions = @purchase_requisition.material_registered_purchase_requisition_positions
		@success = true

		purchase_requisition_positions.each do |purchase_requisition_position|
			purchase_requisition_position_attr = purchase_requisition_position.attributes
			purchase_requisition_position_attr = purchase_requisition_position_attr.merge(params[:material_purchase_requisition_position][purchase_requisition_position.id.to_s])
			@purchase_requisition_position_aux = Material::PurchaseRequisitionPosition.new(purchase_requisition_position_attr)
			@success = @purchase_requisition_position_aux.valid?
			if !@success
				@purchase_requisition_position_aux
				break
			end
		end

		if @success
				@purchase_requisition.update_attribute(:material_purchase_requisition_status_type_id,Material::PurchaseRequisitionStatusType.verify.id)
				purchase_requisition_positions.each do |purchase_requisition_position|
				@success &= purchase_requisition_position.update_attributes(params[:material_purchase_requisition_position][purchase_requisition_position.id.to_s])
				purchase_requisition_position.reload
				purchase_requisition_position.set_quantity_values
			end
		end

		
	end

	def approve
		@title = "Pedido de compra / Aprobar pedido"
    @purchase_requisition = Material::PurchaseRequisition.find(params[:purchase_requisition_id])
		@purchase_requisition_positions = @purchase_requisition.material_verified_purchase_requisition_positions
	end

	def approve_process
		@purchase_requisition = Material::PurchaseRequisition.find(params[:purchase_requisition_id])

		purchase_requisition_positions = @purchase_requisition.material_verified_purchase_requisition_positions
		@success = true


		purchase_requisition_positions.each do |purchase_requisition_position|
			purchase_requisition_position_attr = purchase_requisition_position.attributes
			purchase_requisition_position_attr = purchase_requisition_position_attr.merge(params[:material_purchase_requisition_position][purchase_requisition_position.id.to_s])
			@purchase_requisition_position_aux = Material::PurchaseRequisitionPosition.new(purchase_requisition_position_attr)
			@success = @purchase_requisition_position_aux.valid?
			if !@success
				@purchase_requisition_position_aux
				break
			end
		end

		if @success
			@purchase_requisition.update_attribute(:material_purchase_requisition_status_type_id,Material::PurchaseRequisitionStatusType.approve.id)
			purchase_requisition_positions.each do |purchase_requisition_position|
				@success &= purchase_requisition_position.update_attributes(params[:material_purchase_requisition_position][purchase_requisition_position.id.to_s])
				purchase_requisition_position.reload
				purchase_requisition_position.set_quantity_values
			end
		end
	end

  protected
  
	def current_purchase_requisition_positions_objects
		@purchase_requisition_positions = []
		self.current_purchase_requisition_positions.each do |purchase_requisition_position|
			@purchase_requisition_positions << Material::PurchaseRequisitionPosition.new(purchase_requisition_position)
		end
		@purchase_requisition_positions
	end

	def current_purchase_requisition_positions=(purchase_requisition_positions)
		session[:purchase_requisition_positions] = (session[:purchase_requisition_positions].nil? ? [] : session[:purchase_requisition_positions])
		session[:purchase_requisition_positions] << purchase_requisition_positions
	end

	def current_purchase_requisition_positions
		session[:purchase_requisition_positions].nil? ? [] : session[:purchase_requisition_positions]
	end

	def current_purchase_requisition_positions_clear
		session[:purchase_requisition_positions] =  []
	end

	def default
		@purchase_requisition.create_by = current_user
		@purchase_requisition.posting_date = Time.now.to_date
	end
end
