class Backend::MaterialManagement::ProductionOrdersController < Backend::MaterialManagement::BaseController

	helper_method :current_production_order_positions

  def index
    @title = "Orden de movimiento de mercancia"
    @production_orders = Material::ProductionOrder.all
  end
  
  def new
		@title = "Orden de movimiento de mercancia / Nueva orden"
		current_production_order_positions_clear
    @production_order = Material::ProductionOrder.new
		defaults
  end
  
  def create
    @production_order = Material::ProductionOrder.new(params[:material_production_order])
		defaults
		@success = @production_order.valid?
		
		if current_production_order_positions.empty?
			@success = false
			@production_order.errors.add(:material_production_orden_positions,"debe agregar al menos una posición")
		end
		if @success
			
     
      
      @production_order.save
     
			current_production_order_positions.each do |production_order_position|
				production_order_position.material_production_order = @production_order
				production_order_position.save
			end
		end

  end
  
  def show
		@title = "Orden de movimiento de mercancia / Detalle de orden"
    @production_order = Material::ProductionOrder.find(params[:id])
		@production_order_positions = @production_order.material_production_order_positions
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "ProductionOrder_#{@production_order.id.to_code}",
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
  
  def edit
		@title = "Orden de movimiento de mercancia/ Editar orden"
    @production_order = Material::ProductionOrder.find(params[:id])
  end
  
  def update
    
  end

	def add_position
		@production_order_position = Material::ProductionOrderPosition.new(params[:material_production_order_position])
		@success = @production_order_position.valid?
		if  @success
			self.current_production_order_positions=params[:material_production_order_position]
			@production_order_positions = self.current_production_order_positions
		end
	end

  def set_production_orden_type
    @production_orden_type = Material::ProductionOrderType.find_by_id(params[:material_production_order][:material_production_orden_type_id])
  end

	def current_production_order_positions=production_order_position
	
		session[:current_production_order_positions] = [] if session[:current_production_order_positions].nil?
		session[:current_production_order_positions] << production_order_position
	end

	def current_production_order_positions
		session[:current_production_order_positions] = [] if session[:current_production_order_positions].nil?
		production_order_positions = []
		session[:current_production_order_positions].each do |production_order_position|
			production_order_positions << Material::ProductionOrderPosition.new(production_order_position)
		end
		production_order_positions
	end

	def current_production_order_positions_clear
		session[:current_production_order_positions] = []
	end

	def defaults
		@production_order.requesting_unit = current_user
	end

end
