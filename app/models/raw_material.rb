class RawMaterial < ActiveRecord::Base

  humanize_attributes   :name => "Nombre",
                        :raw_material_category => "Categoría",
                        :packing_material => "Empaquetado",
                        :dossier_dependence => "Depende de la tripa"

  
  has_many :inventories,:as => :category
  has_many :finished_products
  has_many :value_quarter_sheet_color_raw_materials,:conditions => {:active => true}
  has_many :value_quarter_sheet_black_raw_materials,:conditions => {:active => true}
  has_many :value_quarter_sheet_white_raw_materials,:conditions => {:active => true}
  has_many :raw_material_price_definition_set_color_by_components,:conditions => {:active => true}
  has_many :raw_material_price_definition_set_black_by_components,:conditions => {:active => true}
  has_many :value_square_meter_raw_materials
  belongs_to :packing_material
  belongs_to :raw_material_category
  has_one  :value_quarter_sheet_color_raw_material,:conditions => {:active => true}
  has_one  :value_quarter_sheet_black_raw_material,:conditions => {:active => true}
  has_one  :value_quarter_sheet_white_raw_material,:conditions => {:active => true}
  has_one :raw_material_price_definition_set_color_by_component,:conditions => {:active => true}
  has_one :raw_material_price_definition_set_black_by_component,:conditions => {:active => true}
  has_one :value_square_meter_raw_material,:conditions => {:active => true}

  validates_presence_of :name,:raw_material_category
	validates_presence_of :packing_material, :if => Proc.new { |raw_material| raw_material.raw_material_category and (raw_material.raw_material_category.is_a_material_product_type? or raw_material.raw_material_category.is_a_paper_type?) }

  after_create :create_associate_relationship

  

  #
  # Calcula el stock o inventario disponible de la materia prima
  #
  def stock

    inventory = case presentation_unit_type_measurement.name
                  when PresentationUnitTypeMeasurement::SUPERFICIAL
                    inventory_for_superficie_presentation_unit_type_measurement
                  when PresentationUnitTypeMeasurement::LOGITUDINAL
                    inventory_for_longitudinal_presentation_unit_type_measurement
                  else
                    #TODO LOGGER
                    0
                end

     

    invoiced = case presentation_unit_type_measurement.name
              when PresentationUnitTypeMeasurement::SUPERFICIAL
                invoiced_for_superficie_presentation_unit_type_measurement
              when PresentationUnitTypeMeasurement::LOGITUDINAL
                invoiced_for_longitudinal_presentation_unit_type_measurement
              else
                #TODO LOGGER
                0
            end

    inventory - invoiced
  end

  #
  # Inventario para presentation_unit_type_measurement del tipo SUPERFICIAL
  #

  def inventory_for_superficie_presentation_unit_type_measurement
    surface = packing_material.presentation_unit_type_measure.side_dimension_x * packing_material.presentation_unit_type_measure.side_dimension_y
    inventories.map(& :quantity).inject(0) { |s,v| s += v } * surface
  end

  #
  # Inventario para presentation_unit_type_measurement del tipo SUPERFICIAL
  #

  def inventory_for_longitudinal_presentation_unit_type_measurement
    inventories.map(& :quantity).inject(0) { |s,v| s += v } * packing_material.quantity
  end

  #
  # Facturas para presentation_unit_type_measurement del tipo SUPERFICIAL
  #

  def invoiced_for_superficie_presentation_unit_type_measurement
    finished_products.each do |finished_product|
      finished_product.products.each do |product|
        product.product_by_invoices.each do |product_by_invoice|
          total_presentation_unit_type_to_use = product_by_invoice.total_presentation_unit_type_to_use
          finished_product.presentation_unit_type.presentation_unit_type_conversions.each do |presentation_unit_type_conversion|
            if packing_material.presentation_unit_type_id.eql?(presentation_unit_type_conversion.presentation_unit_type_to_id)
              invoiced += (total_presentation_unit_type_to_use*presentation_unit_type_conversion.proportion).to_i
            end
          end
        end
      end
    end
  end

  #
  # Facturas para presentation_unit_type_measurement del tipo SUPERFICIAL
  #

  def invoiced_for_longitudinal_presentation_unit_type_measurement
    finished_products.each do |finished_product|
      finished_product.products.each do |product|
        product.product_by_invoices.each do |product_by_invoice|
          total_presentation_unit_type_to_use = product_by_invoice.total_presentation_unit_type_to_use
          finished_product.presentation_unit_type.presentation_unit_type_conversions.each do |presentation_unit_type_conversion|
            if packing_material.presentation_unit_type_id.eql?(presentation_unit_type_conversion.presentation_unit_type_to_id)
              invoiced += (total_presentation_unit_type_to_use*presentation_unit_type_conversion.proportion).to_i
            end
          end
        end
      end
    end
  end

  #
  # retorma todas las unidades de presentacion asociadoas al empaquetado
  #
  def presentation_unit_types
    [packing_material.presentation_unit_type] + packing_material.presentation_unit_type.presentation_unit_type_conversions.map(& :presentation_unit_type_to)
  end

  #
  # retorna la medida asociada al empaquetado
  #
  def presentation_unit_type_measure
    packing_material.presentation_unit_type_measure
  end

  #
  # Busca todos las materias primas donde el finished_product tenga como categoria el finished_product_category_type
  #

  def self.find_all_by_finished_product_category_type(finished_product_category_type)
    raw_materials = []
    finished_product_category_type.finished_products.each do |finished_product|
      raw_materials << finished_product.raw_material
    end
    raw_materials
  end


  #
  # Crear el registro enel modelo asociado de acuerdo al RawMaterialCategory.model_relationship
  #

  def create_associate_relationship
    if raw_material_category.has_any_model_relationship?
      model_relationship = eval(raw_material_category.model_relationship)
      model_relationship = model_relationship.new(:name => name,:full_name =>name ,:tag_name =>name.to_underscore.downcase,:raw_material_id => id)
      model_relationship.save
    end
  end

  #
  # retorna para un numero dado el menor valor de cuarto de  pliego a color
  #
  def min_value_quarter_sheet_color(value)
    
  end

  #
  # Precio fijo por tipo de componente a color
  #
  def price_definition_set_by_components(quantity,value_quarter_sheet,component,color_mode,options={})
    accumulate_t = 0
    accumulate_tr = 0
    
    
    if options[:by_price_definition_set]
      result = eval("raw_material_price_definition_set_#{color_mode}_by_components").first(:conditions => ["component_id = ? AND component_type = ?",component.id,component.class.to_s])
      if result
        accumulate_t = result.amount_t*quantity
        accumulate_tr = result.amount_tr*quantity
      else
        result = eval("raw_material_price_definition_set_#{color_mode}_by_components").first(:conditions => ["component_type = ? AND base_amount = ?",component.class.to_s,true])
        accumulate_t = result.amount_t*value_quarter_sheet
        accumulate_tr = result.amount_tr*value_quarter_sheet
      end
    else
      result = eval("raw_material_price_definition_set_#{color_mode}_by_components").first(:conditions => ["component_type = ? AND base_amount = ?",component.class.to_s,true])
      accumulate_t = result.amount_t*value_quarter_sheet
      accumulate_tr = result.amount_tr*value_quarter_sheet
    end
    {:t =>accumulate_t.round(2),:tr => accumulate_tr.round(2)}
  end





    def self.create_value_quarter_sheet
      self.all.each do |item|
        if !item.value_quarter_sheet_color_raw_material
          ValueQuarterSheetColorRawMaterial.create(:raw_material_id => item.id)
        end
        if !item.value_quarter_sheet_black_raw_material
            ValueQuarterSheetBlackRawMaterial.create(:raw_material_id => item.id)
        end
        if !item.value_quarter_sheet_white_raw_material
            ValueQuarterSheetWhiteRawMaterial.create(:raw_material_id => item.id)
        end
      end
    end

	#
  #Busca de acuerdo al parametro <b>attr</b>, cualquier producto con el valor <b>value<b/>
  #
  def self.find_by_autocomplete(attrs,value)
    rows = []
    clausules = []
    values = []
    conditions = []

    attrs = [attrs] if not attrs.kind_of?(Array)

    attrs.each do |attr|
      clausules << "lower(#{attr}) LIKE lower(?)"
      values << "%#{value}%"
    end

    conditions << clausules.join(" OR ")
    conditions.concat( values )


    raw_materials = all(:conditions => conditions,:limit => 5)
    raw_materials.each do |raw_material|
     rows << {
                "label" => raw_material[:name],
                "id" => raw_material[:id],
                "name" => raw_material[:name],
                "reference_code" => raw_material[:reference_code],
								"raw_material_category" => raw_material[:raw_material_category],
								"packing_material" => raw_material[:packing_material_id],
								"packing_materials" => raw_material.raw_material_category.packing_materials.map(&:min),
                "code_response" => (true ? "ok" : "no-ok")
              }
    end
    JSON.generate(rows)
  end

  private

    #
    # devuelve el presentation_unit_type_measurement de acuerdo al raw_material
    #
    def presentation_unit_type_measurement
      packing_material.presentation_unit_type_measurement
    end


end
