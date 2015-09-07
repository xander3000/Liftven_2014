class Backend::MaterialManagement::PurchaseOrdersController < Backend::MaterialManagement::BaseController
helper_method :current_purchase_order_positions_objects
	
  def index
		@title = "Ordenes de compra"
    @purchase_orders = Material::PurchaseOrder.all
  end

  def show
		@title = "Ordenes de compra / Detalle de orden"
    @purchase_order = Material::PurchaseOrder.find(params[:id])
		@purchase_order_positions = @purchase_order.material_purchase_order_positions
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "PurchaseOrder_#{@purchase_order.id.to_code}",
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

  def new
		@title = "Ordenes de compra / Nueva orden"
		current_purchase_order_positions_clear
    @purchase_order = Material::PurchaseOrder.new
		
		default
  end

  def create
    @purchase_order = Material::PurchaseOrder.new(params[:material_purchase_order])
		default
		
		@success = @purchase_order.valid?
		@success &= @purchase_order.has_added_item_positions?(current_purchase_order_positions_objects)
		
		if @success
			@purchase_order.save
			current_purchase_order_positions_objects.each do |current_purchase_order_position|
				current_purchase_order_position.material_purchase_order = @purchase_order
				current_purchase_order_position.save
			end
			current_purchase_order_positions_clear
		end

  end

  def edit
    @purchase_order = Material::PurchaseOrder.find(params[:id])
  end

  def update
    @purchase_order = Material::PurchaseOrder.find(params[:id])
  end

	def add
		@purchase_order_position = Material::PurchaseOrderPosition.new(params[:material_purchase_order_position])
		@success = @purchase_order_position.valid?
		if @success
			self.current_purchase_order_positions=params[:material_purchase_order_position]
		end
	end

	def get_quotation_requisition_supplier
		current_purchase_order_positions_clear
		@suppplier = Supplier.find_by_id(params[:material_purchase_order][:supplier_id])
		if @suppplier
			@suppplier.material_quotation_requisition_position_positions_tendered.each do |position|
			order_position = Material::PurchaseOrderPosition.new
			order_position.material_raw_material = position.material_raw_material
			order_position.quantity = position.quantity
			order_position.delivery_date = position.material_quotation_requisition.delivery_date
			order_position.material_order_measure_unit = position.material_order_measure_unit
			if position.supplier_1.eql?(@suppplier)
				sub_total = position.sub_total_supplier_1
				total = position.total_supplier_1
			elsif position.supplier_2.eql?(@suppplier)
				sub_total = position.sub_total_supplier_2
				total = position.total_supplier_2
			else
				sub_total = position.sub_total_supplier_3
				total = position.total_supplier_3
			end
			order_position.sub_total = sub_total
			order_position.total = total
			self.current_purchase_order_positions=order_position.attributes
			end
			@success = true
		end
		
		
	end

	def current_purchase_order_positions_objects
		@purchase_order_positions = []
		self.current_purchase_order_positions.each do |purchase_order_position|
			@purchase_order_positions << Material::PurchaseOrderPosition.new(purchase_order_position)
		end
		@purchase_order_positions
	end

	def current_purchase_order_positions=(purchase_order_positions)
		session[:purchase_order_positions] = (session[:purchase_order_positions].nil? ? [] : session[:purchase_order_positions])
		session[:purchase_order_positions] << purchase_order_positions
	end

	def current_purchase_order_positions
		session[:purchase_order_positions].nil? ? [] : session[:purchase_order_positions]
	end

	def current_purchase_order_positions_clear
		session[:purchase_order_positions] = nil
	end

	def default
		@purchase_order.create_by = current_user
		@purchase_order.posting_date = Time.now.to_date
		@purchase_order.currency_type = CurrencyType.default
	end

	protected

end
