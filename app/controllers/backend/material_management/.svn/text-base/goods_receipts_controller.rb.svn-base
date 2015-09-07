class Backend::MaterialManagement::GoodsReceiptsController < Backend::MaterialManagement::BaseController
helper_method :current_goods_receipt_positions_objects

  def index
    @goods_receipts = Material::GoodsReceipt.all
  end

  def show
    @goods_receipt = Material::GoodsReceipt.find(params[:id])
		@goods_receipt_positions = @goods_receipt.goods_receipt_positions
  end

  def new
		session[:goods_receipt_positions] = nil
    @goods_receipt = Material::GoodsReceipt.new
		default
  end

  def create
    @goods_receipt = Material::GoodsReceipt.new(params[:goods_receipt])
		@goods_receipt.supplier = @goods_receipt.purchase_order.supplier
		default
		@goods_receipt.has_added_item_positions?(current_goods_receipt_positions_objects)
		@success = @goods_receipt.valid?

		if @success
			@goods_receipt.save
			current_goods_receipt_positions_objects.each do |current_goods_receipt_position|
				current_goods_receipt_position.goods_receipt = @goods_receipt
				current_goods_receipt_position.save
			end
		end

  end

  def edit
    @goods_receipt = Material::GoodsReceipt.find(params[:id])
  end

  def update
    @goods_receipt = Material::GoodsReceipt.find(params[:id])
  end

	def add
		@goods_receipt_position = Material::GoodsReceiptPosition.new(params[:goods_receipt_position])
		@success = @goods_receipt_position.valid?
		if @success
			self.current_goods_receipt_positions=params[:goods_receipt_position]
		end
	end

	def confirm_purchase_order
		clear_current_goods_receipt_positions
		@purcharse_order = Material::PurchaseOrder.find_by_id(params[:purchase_order_id])
		if @purcharse_order
			@purcharse_order.purchase_order_positions.each do |purchase_order_position|
				attributes = purchase_order_position.attributes
				attributes.delete("id")
				attributes.delete("purchase_order_id")
				attributes.delete("sub_total")
				attributes.delete("total")

				self.current_goods_receipt_positions=attributes
			end
			
		end
	end

	def current_goods_receipt_positions_objects
		@goods_receipt_positions = []
		self.current_goods_receipt_positions.each do |goods_receipt_position|
			@goods_receipt_positions << Material::GoodsReceiptPosition.new(goods_receipt_position)
		end
		@goods_receipt_positions
	end

	def current_goods_receipt_positions=(goods_receipt_positions)
		session[:goods_receipt_positions] = (session[:goods_receipt_positions].nil? ? [] : session[:goods_receipt_positions])
		if goods_receipt_positions.kind_of?(Array)
			session[:goods_receipt_positions].concat(goods_receipt_positions)
		else
			session[:goods_receipt_positions] << goods_receipt_positions
		end
		
	end

	def current_goods_receipt_positions
		session[:goods_receipt_positions].nil? ? [] : session[:goods_receipt_positions]
	end

	def clear_current_goods_receipt_positions
		session[:goods_receipt_positions] = []
	end


	def default
		@goods_receipt.create_by = current_user
		@goods_receipt.posting_date = Time.now.to_date
	end

	protected

  def set_title
    @title = "Movimiento de Mercancia"
  end
end
