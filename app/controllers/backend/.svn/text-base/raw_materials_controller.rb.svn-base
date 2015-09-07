class Backend::RawMaterialsController < Backend::BaseController
  #before_filter :defaults,:only => ["show","edit","update"]
  
  def index
    @raw_material_categories = RawMaterialCategory.all
				p "---------------------"
		p controller_class_name
		p controller_name
		p controller_path
		p controller_name
		p action_name
		p Backend::BaseController.subclasses

		
  end

  def new
    @raw_material = RawMaterial.new
    @inventory = Inventory.new

#    @value_quarter_sheet_color_raw_material = ValueQuarterSheetColorRawMaterial.new
#    @value_quarter_sheet_black_raw_material = ValueQuarterSheetBlackRawMaterial.new
#    @value_quarter_sheet_white_raw_material = ValueQuarterSheetWhiteRawMaterial.new
  end

  def create
    @raw_material = RawMaterial.new(params[:raw_material])
    if @raw_material.raw_material_category.is_a_paper_type?
      @value_quarter_sheet_color_raw_material = ValueQuarterSheetColorRawMaterial.new(params[:value_quarter_sheet_color_raw_material])
      @value_quarter_sheet_black_raw_material = ValueQuarterSheetBlackRawMaterial.new(params[:value_quarter_sheet_black_raw_material])
      @value_quarter_sheet_white_raw_material = ValueQuarterSheetWhiteRawMaterial.new(params[:value_quarter_sheet_white_raw_material])
    elsif @raw_material.raw_material_category.is_a_material_product_type?
      @value_square_meter_raw_material = ValueSquareMeterRawMaterial.new(params[:value_square_meter_raw_material])
    end


    @success = @raw_material.valid?
    if @success
      @raw_material.save
      if @raw_material.raw_material_category.is_a_paper_type?
        @value_quarter_sheet_color_raw_material.raw_material = @raw_material
        @value_quarter_sheet_black_raw_material.raw_material = @raw_material
        @value_quarter_sheet_white_raw_material.raw_material = @raw_material
        @value_quarter_sheet_color_raw_material.save
        @value_quarter_sheet_black_raw_material.save
        @value_quarter_sheet_white_raw_material.save
      elsif @raw_material.raw_material_category.is_a_material_product_type?
        @value_square_meter_raw_material.raw_material = @raw_material
        @value_square_meter_raw_material.save
      end

      @inventories = @raw_material.inventories
      
      @raw_material_categories = RawMaterialCategory.all
    end
  end
  
  def select_packing_material
    @packing_material = PackingMaterial.find_by_id(params[:raw_material][:packing_material_id].to_i)
  end

  def select_raw_material_category
    raw_material = RawMaterial.find_by_id(params[:raw_material_id].to_i)
    @raw_material_category = RawMaterialCategory.find_by_id(params[:raw_material][:raw_material_category_id])

    if raw_material
      @packing_material_id = raw_material.packing_material_id
    else
      @packing_material_id = 0
    end

    if @raw_material_category.is_a_paper_type?
      @value_quarter_sheet_color_raw_material  = raw_material ? (raw_material.value_quarter_sheet_color_raw_material || ValueQuarterSheetColorRawMaterial.new) : ValueQuarterSheetColorRawMaterial.new
      @value_quarter_sheet_black_raw_material  = raw_material ? (raw_material.value_quarter_sheet_black_raw_material || ValueQuarterSheetBlackRawMaterial.new) : ValueQuarterSheetBlackRawMaterial.new
      @value_quarter_sheet_white_raw_material  = raw_material ? (raw_material.value_quarter_sheet_white_raw_material || ValueQuarterSheetWhiteRawMaterial.new) : ValueQuarterSheetWhiteRawMaterial.new
    elsif @raw_material_category.is_a_material_product_type?
      @value_square_meter_raw_material = raw_material ? (raw_material.value_square_meter_raw_material || ValueSquareMeterRawMaterial.new) : ValueSquareMeterRawMaterial.new
    end

    
  end

  def show
    @raw_material = RawMaterial.find(params[:id])
    @raw_material_category = @raw_material.raw_material_category
    
    if @raw_material_category.is_a_paper_type?
      @value_quarter_sheet_color_raw_material  = @raw_material.value_quarter_sheet_color_raw_material || ValueQuarterSheetColorRawMaterial.new
      @value_quarter_sheet_black_raw_material  = @raw_material.value_quarter_sheet_black_raw_material || ValueQuarterSheetBlackRawMaterial.new
      @value_quarter_sheet_white_raw_material  = @raw_material.value_quarter_sheet_white_raw_material || ValueQuarterSheetWhiteRawMaterial.new
    elsif @raw_material_category.is_a_material_product_type?
      @value_square_meter_raw_material = @raw_material.value_square_meter_raw_material || ValueSquareMeterRawMaterial.new
    end
  end

  def edit
		logger.info("*** BEGIN #{controller_name} ***")
    @raw_material = RawMaterial.find(params[:id])
    @raw_material_category = @raw_material.raw_material_category

#    if @raw_material_category.is_a_paper_type?
#      @value_quarter_sheet_color_raw_material  = @raw_material.value_quarter_sheet_color_raw_material || ValueQuarterSheetColorRawMaterial.new
#      @value_quarter_sheet_black_raw_material  = @raw_material.value_quarter_sheet_black_raw_material || ValueQuarterSheetBlackRawMaterial.new
#      @value_quarter_sheet_white_raw_material  = @raw_material.value_quarter_sheet_white_raw_material || ValueQuarterSheetWhiteRawMaterial.new
#    elsif @raw_material_category.is_a_material_product_type?
#      @value_square_meter_raw_material = @raw_material.value_square_meter_raw_material || ValueSquareMeterRawMaterial.new
#    end
		logger.info("*** END #{controller_name}***")
  end

  def update
    @raw_material = RawMaterial.find(params[:id])
    @success = @raw_material.update_attributes(params[:raw_material])
    @raw_material_category = @raw_material.raw_material_category
    
    if @raw_material_category.is_a_paper_type?
      @value_quarter_sheet_color_raw_material  = @raw_material.value_quarter_sheet_color_raw_material || ValueQuarterSheetColorRawMaterial.new(:raw_material_id => @raw_material.id)
      @value_quarter_sheet_black_raw_material  = @raw_material.value_quarter_sheet_black_raw_material || ValueQuarterSheetBlackRawMaterial.new(:raw_material_id => @raw_material.id)
      @value_quarter_sheet_white_raw_material  = @raw_material.value_quarter_sheet_white_raw_material || ValueQuarterSheetWhiteRawMaterial.new(:raw_material_id => @raw_material.id)

      @value_quarter_sheet_color_raw_material.update_attributes(params[:value_quarter_sheet_color_raw_material])
      @value_quarter_sheet_black_raw_material.update_attributes(params[:value_quarter_sheet_black_raw_material])
      @value_quarter_sheet_white_raw_material.update_attributes(params[:value_quarter_sheet_white_raw_material])

    elsif @raw_material_category.is_a_material_product_type?
      @value_square_meter_raw_material = @raw_material.value_square_meter_raw_material || ValueSquareMeterRawMaterial.new(:raw_material_id => @raw_material.id)
      @value_square_meter_raw_material.update_attributes(params[:value_square_meter_raw_material])

    end

    @raw_material_categories = RawMaterialCategory.all if @success
    
  end

  def new_inventory
    @raw_material = RawMaterial.find(params[:raw_material_id])
    @inventory = Inventory.new
  end

  def add_inventory
    @raw_material = RawMaterial.find(params[:raw_material_id])
    inventory = Inventory.new(params[:inventory])
    inventory.user_id = current_user
    @success = inventory.valid?
    if @success
      inventory.category = @raw_material
      inventory.save
    end
  end

  def remove_inventory
    @raw_material = RawMaterial.find(params[:raw_material_id])
    inventory = Inventory.find(params[:inventory_id])
    @success = inventory.delete
  end

	def autocomplete_by_name
    result = RawMaterial.find_by_autocomplete("name",params[:term])
    render :json => result
  end

	def packing_material_by_raw_material_category
		@packing_materials = RawMaterialCategory.find(params[:raw_material_category_id]).packing_materials
	end

  protected

  def set_title
    @title = "Materiales"
  end

  def defaults

    if (@raw_material and @raw_material.raw_material_category.is_a_paper_type?) or (@raw_material_category and @raw_material_category.is_a_paper_type?)
      @value_quarter_sheet_color_raw_material  = @raw_material.value_quarter_sheet_color_raw_material || ValueQuarterSheetColorRawMaterial.new
      @value_quarter_sheet_black_raw_material  = @raw_material.value_quarter_sheet_black_raw_material || ValueQuarterSheetBlackRawMaterial.new
      @value_quarter_sheet_white_raw_material  = @raw_material.value_quarter_sheet_white_raw_material || ValueQuarterSheetWhiteRawMaterial.new
    elsif (@raw_material and @raw_material.is_a_material_product_type?.is_a_paper_type?) or (@raw_material_category and @raw_material_category.is_a_material_product_type?)
      @value_square_meter_raw_material = @raw_material.value_square_meter_raw_material || ValueSquareMeterRawMaterial.new
    end
  end

end
