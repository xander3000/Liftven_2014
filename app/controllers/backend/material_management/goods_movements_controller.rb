class Backend::MaterialManagement::GoodsMovementsController < Backend::MaterialManagement::BaseController
helper_method :current_goods_movement_positions_objects
  
  def index
		@title = "Movimiento de Mercancia"
    @goods_movements = Material::GoodsMovement.all
  end

	def autocomplete_doc_reason_type_by_supplier
		result = eval(current_goods_movement_reason_type).find_by_autocomplete_term("contacts.fullname",params[:term])
    render :json => result
	end

  def show
		@title = "Movimiento de Mercancia / Detalle de movimiento"
    @goods_movement = Material::GoodsMovement.find(params[:id])
		@goods_movement_positions = @goods_movement.material_goods_movement_positions
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "GoodsMovement_#{@goods_movement.id.to_code}",
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
		@title = "Movimiento de Mercancia / Nuevo movimiento"
		session[:material_goods_movement_positions] = nil
		current_goods_movement_reason_type_clear
    @goods_movement = Material::GoodsMovement.new
		default
  end




  def create
    @goods_movement = Material::GoodsMovement.new(params[:material_goods_movement])
		default
		
		
		@success = @goods_movement.valid?
		@success &= @goods_movement.has_added_item_positions?(current_goods_movement_positions_objects)
		@success &= @goods_movement.has_raw_material_stock_item_positions?(current_goods_movement_positions_objects)

		if @success
			
			@goods_movement.save
				current_goods_movement_positions_objects.each do |current_goods_movement_position|
					current_goods_movement_position.material_goods_movement = @goods_movement
					current_goods_movement_position.save
				end
      @goods_movement.update_stock_by_raw_material
		end
  end

  def edit
    @goods_movement = Material::GoodsMovement.find(params[:id])
  end

  def update
    @goods_movement = Material::GoodsMovement.find(params[:id])
  end

	def add
		@goods_movement_position = Material::GoodsMovementPosition.new(params[:material_goods_movement_position])
		@success = @goods_movement_position.valid?
		if @success
			self.current_goods_movement_positions=params[:material_goods_movement_position]
		end
	end

	def set_goods_movement_type
		current_goods_movement_reason_type_clear
		goods_movement_type = Material::GoodsMovementType.find_by_id(params[:material_goods_movement][:material_goods_movement_type_id].to_i)
		if goods_movement_type
			@goods_movement_reasons = goods_movement_type.material_goods_movement_reasons
		else
			@goods_movement_reasons = []
		end
	end

	def set_goods_movement_reason
		current_goods_movement_reason_type_clear
		@goods_movement_reason = Material::GoodsMovementReason.find_by_id(params[:material_goods_movement][:material_goods_movement_reason_id])
		self.current_goods_movement_reason_type = @goods_movement_reason.tag_name if @goods_movement_reason
	end



	def confirm_doc

		clear_current_goods_movement_positions
		@show_position = false

		@doc = eval(current_goods_movement_reason_type).find_by_id(params[:doc_id])
		@goods_movement_type = Material::GoodsMovementType.find_by_id(params[:goods_movement_type_id])
		
		if @doc

			
				@doc.material_positions.each do |material_position|
				
					good_movement_position = Material::GoodsMovementPosition.new
					good_movement_position.material_raw_material = material_position.material_raw_material
					good_movement_position.quantity = material_position.quantity
					self.current_goods_movement_positions=good_movement_position.attributes

				end
			

		else
			@errors = ["Pedido #{params[:doc_id]} no existe, por favor verificar!"]
		end
	
	end

	protected

	def current_goods_movement_positions_objects
		@goods_movement_positions = []
		self.current_goods_movement_positions.each do |goods_movement_position|
			@goods_movement_positions << Material::GoodsMovementPosition.new(goods_movement_position)
		end
		@goods_movement_positions
	end

	def current_goods_movement_positions=(goods_movement_positions)
		session[:material_goods_movement_positions] = (session[:material_goods_movement_positions].nil? ? [] : session[:material_goods_movement_positions])
		if goods_movement_positions.kind_of?(Array)
			session[:material_goods_movement_positions].concat(goods_movement_positions)
		else
			session[:material_goods_movement_positions] << goods_movement_positions
		end

	end

	def current_goods_movement_positions
		session[:material_goods_movement_positions].nil? ? [] : session[:material_goods_movement_positions]
	end

	def clear_current_goods_movement_positions
		session[:material_goods_movement_positions] = []
	end

	def current_goods_movement_reason_type=goods_movement_reason_type
		session[:material_goods_movement_reason_type] = goods_movement_reason_type
	end

	def current_goods_movement_reason_type
		session[:material_goods_movement_reason_type]
	end

	def current_goods_movement_reason_type_clear
		session[:material_goods_movement_reason_type] = nil
	end

	def default
		@goods_movement.create_by = current_user
		@goods_movement.posting_date = Time.now.to_date
	end

	


end
