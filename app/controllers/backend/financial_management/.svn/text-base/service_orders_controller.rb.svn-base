class Backend::FinancialManagement::ServiceOrdersController < Backend::FinancialManagement::BaseController
  helper_method :current_service_order_positions_objects

  def index
		@title = "Ordenes de servicio"
    @service_orders = Accounting::ServiceOrder.all
  end

  def show
		@title = "Ordenes de servicio / Detalle de orden"
    @service_order = Accounting::ServiceOrder.find(params[:id])
		@service_order_positions = @service_order.accounting_service_order_positions
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "ServiceOrder_#{@service_order.id.to_code}",
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
		@title = "Ordenes de servicio / Nueva orden"
		current_service_order_positions_clear
    @service_order = Accounting::ServiceOrder.new

		default
  end

  def create
    @service_order = Accounting::ServiceOrder.new(params[:accounting_service_order])
		default

		@success = @service_order.valid?
		@success &= @service_order.has_added_item_positions?(current_service_order_positions_objects)

		if @success
			@service_order.save
			current_service_order_positions_objects.each do |current_service_order_position|
				current_service_order_position.accounting_service_order = @service_order
				current_service_order_position.save
			end
			current_service_order_positions_clear
		end

  end

  def edit
    @service_order = Accounting::ServiceOrder.find(params[:id])
  end

  def update
    @service_order = Accounting::ServiceOrder.find(params[:id])
  end

	def add
		@service_order_position = Accounting::ServiceOrderPosition.new(params[:accounting_service_order_position])
		@success = @service_order_position.valid?
		if @success
			self.current_service_order_positions=params[:accounting_service_order_position]
		end
	end

	def get_quotation_requisition_supplier
		current_service_order_positions_clear
		@suppplier = Supplier.find_by_id(params[:accounting_service_order][:supplier_id])
		if @suppplier
			@suppplier.material_quotation_requisition_position_positions_tendered.each do |position|
			order_position = Accounting::ServiceOrderPosition.new
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
			self.current_service_order_positions=order_position.attributes
			end
			@success = true
		end


	end

	def current_service_order_positions_objects
		@service_order_positions = []
		self.current_service_order_positions.each do |service_order_position|
			@service_order_positions << Accounting::ServiceOrderPosition.new(service_order_position)
		end
		@service_order_positions
	end

	def current_service_order_positions=(service_order_positions)
		session[:service_order_positions] = (session[:service_order_positions].nil? ? [] : session[:service_order_positions])
		session[:service_order_positions] << service_order_positions
	end

	def current_service_order_positions
		session[:service_order_positions].nil? ? [] : session[:service_order_positions]
	end

	def current_service_order_positions_clear
		session[:service_order_positions] = nil
	end

	def default
		@service_order.create_by = current_user
		@service_order.posting_date = Time.now.to_date
		@service_order.currency_type = CurrencyType.default
	end

	protected

end
