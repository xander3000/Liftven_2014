class Material::RawMaterial < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end


  humanize_attributes   :material_base_measure_unit => "Unidad medida base",
                        :material_raw_material_category => "Categoria/Grupo",
                        :material_external_raw_material_category => "Categoria/Grupo externo",
                        :material_weight_unit => "Unidad de peso",
                        :material_volume_unit => "Unidad de volumen",
                        :material_ean_category => "Tipo EAN",
                        :material_raw_material_packaging_category => "Categoria Embalaje",
                        :id => "Id",
                        :name => "Nombre",
                        :old_id => "N° antiguo material",
                        :valid_from => "Valido desde",
                        :gross_weight => "Peso bruto",
                        :net_weight => "Peso neto",
                        :volume => "Volumen",
                        :side_dimension => "Tamaño/Dimensión",
                        :ean_upc_code => "Código EAN/UPC",
                        #purchasing
                        :material_order_measure_unit => "Unidad medida pedido",
                        :material_purchasing_group => "Grupo de compras",
                        :material_raw_material_freight_type => "Grup. porte material",
                        #:material_packing_material => "Empaquetado",
                        :tax_exempt => "¿Material regulado?",
                        :automatic_po => "¿Generar pedido automático?",
                        :goods_receipt_processing_time => "Tiempo tratamiento EM",
                        #store
                        :material_issue_measure_unit => "Unidad medida salida",
                        :material_picking_area => "Área de picking",
                        :material_temperature_condition => "Condiciones temperatura",
                        :material_storage_condition => "Cond. almacenaje",
                        :material_hazardou_substance_type => "N° sustancia pelig.",
                        :material_prescription_container_type => "Prescripción envase",
                        :material_cycle_inventory_type => "Ind. invetario cíclico",
                        :material_time_unit => "Unidad tiempo",
                        :material_expiry_time_type => "Ind.per.fe.caducidad",
                        :storage => "Ubicación",
                        :max_storage_period => "Tmp. almacenaje máx.",
                        :min_remaining_shelf_life => "Tmp.min.durac.rest.",
                        :total_shelf_life =>  "Dura.total conservac",
                        #accounting
                        :material_valoration_category => "Categoría valoración",
                        :material_valoration_type => "Tipo valoración",
                        :material_price_control_type => "Control de precios",
                        :material_price_determination_type => "Determ.precio",
                        :price_unit => "Cantidad base",
                        :moving_price => "Precio variable",
                        :standard_price => "Precio estándar",
                        :future_price  => "Precio futuro",
                        :previous_price => "Precio anterior",
                        :last_price_change => "Ult.modif.precio",
                        :total_stock => "Stock total",
                        :total_value => "Valor total",
                        :tax_price_1  => "Precio fiscal 1",
                        :commercial_price_1  => "Precio contable 1",
                        :tax_price_2  => "Precio fiscal 2",
                        :commercial_price_2  => "Precio contable 2",
                        :tax_price_3  => "Precio fiscal 3",
                        :commercial_price_3  => "Precio contable 3",
                        #stock
                        :material_inventory_blocking_type => "Bloqueo inventario",
                        :unrestricted_use_stock => "Libre utilización",
                        :min_stock => "Stock mínimo",
                        :max_stock => "Stock máximo",
                        :unrestricted_consignment => "Condig. libre utiliz",
                        :restricted_use_stock => "Stock no libre",
                        :restricted_consignment => "Consig. no libre",
                        :in_quality_inspection => "En control calidad",
                        :consignment_inspection => "Consig. control cal.",
                        :blocked => "Bloqueado",
                        :blocked_consignment => "Consig. bloqueada",
                        :returns => "Devoluciones",
                        :stock_transfer => "En traslado",
                        :transfer => "En traslado (centro)",
                        :stock_transit => "stock en tránsito",
                        :raw_material_category => "Categoría",
                        :packing_material => "Empaquetado",
                        :dossier_dependence => "Depende de la tripa"

  
              belongs_to  	:material_base_measure_unit,:class_name => "Material::MeasureUnit"
              belongs_to  	:material_raw_material_category,:class_name => "Material::RawMaterialCategory"
              belongs_to  	:material_external_raw_material_category,:class_name => "Material::RawMaterialCategory"
              belongs_to  	:material_weight_unit,:class_name => "Material::WeightUnit"
              belongs_to  	:material_volume_unit,:class_name => "Material::VolumeUnit"
              belongs_to  	:material_ean_category,:class_name => "Material::EanCategory"
              belongs_to  	:material_raw_material_packaging_category,:class_name => "Material::RawMaterialPackagingCategory"
              belongs_to  	:material_order_measure_unit,:class_name => "Material::MeasureUnit"
              belongs_to  	:material_purchasing_group,:class_name => "Material::PurchasingGroup"
              belongs_to  	:material_raw_material_freight_type,:class_name => "Material::RawMaterialFreightType"
              #belongs_to  	:material_packing_material,:class_name => "Material::PackingMaterial"
              belongs_to  	:material_issue_measure_unit,:class_name => "Material::MeasureUnit"
              belongs_to  	:material_picking_area,:class_name => "Material::PickingArea"
              belongs_to  	:material_temperature_condition,:class_name => "Material::TemperatureCondition"
              belongs_to  	:material_storage_condition,:class_name => "Material::StorageCondition"
              belongs_to  	:material_hazardou_substance_type,:class_name => "Material::HazardouSubstanceType"
              belongs_to  	:material_prescription_container_type,:class_name => "Material::PrescriptionContainerType"
              belongs_to  	:material_cycle_inventory_type,:class_name => "Material::CycleInventoryType"
              belongs_to  	:material_time_unit,:class_name => "Material::TimeUnit"
              belongs_to  	:material_expiry_time_type,:class_name => "Material::ExpiryTimeType"
              belongs_to  	:material_valoration_category,:class_name => "Material::ValorationCategory"
              belongs_to  	:material_valoration_type,:class_name => "Material::ValorationType"
              belongs_to  	:material_price_control_type,:class_name => "Material::PriceControlType"
              belongs_to  	:material_price_determination_type,:class_name => "Material::PriceDeterminationType"
              belongs_to  	:material_inventory_blocking_type,:class_name => "Material::InventoryBlockingType"
							has_many			:material_goods_movement_positions,:class_name => "Material::GoodsMovementPosition",:foreign_key => "material_raw_material_id"
							has_many :multimedia_files,:as => :proxy
							has_attached_file :attach,
																:url  => "/attachments/raw_materials/:id/:basename.:extension",
																:path => ":rails_root/public/attachments/raw_materials/:id/:basename.:extension"

  validates_presence_of :name,
                        :material_base_measure_unit,
                        :material_raw_material_category,
                        :material_external_raw_material_category,
                        :material_order_measure_unit,
                        #:material_packing_material,
                        :material_issue_measure_unit,
                        :material_valoration_type,
                        :material_price_control_type,
                        :price_unit,
                        :moving_price,
                        :standard_price,
                        :last_price_change,
                        :material_inventory_blocking_type



  #############################################################################################
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

  validates_presence_of :name#,:raw_material_category
	#validates_presence_of :packing_material, :if => Proc.new { |raw_material| raw_material.raw_material_category and (raw_material.raw_material_category.is_a_material_product_type? or raw_material.raw_material_category.is_a_paper_type?) }

  after_create :create_associate_relationship



  ##############################################################################################






  def code
    max = self.class.maximum("id")
    ((max ? max : 0) + 1).to_code
  end


  #
  # Retorna el la url del thumbnail
  #

  def thumbnail_url
      attach.url(:thumb)
  end

  #
  # Retorna el la url para eliminar el objeto
  #

  def delete_url
      attach.url
  end

  #
  # Methodo REST para eliminar
  #
  def delete_type
    "DELETE"
  end

  #
  #  Retorna el la url para un enlace web
  #
  def web_url(site_url)
    "#{site_url}#{attach.url}"
  end

  #################################################################################################

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
#    if raw_material_category.has_any_model_relationship?
#      model_relationship = eval(raw_material_category.model_relationship)
#      model_relationship = model_relationship.new(:name => name,:full_name =>name ,:tag_name =>name.to_underscore.downcase,:raw_material_id => id)
#      model_relationship.save
#    end
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


    raw_materials = all(:conditions => conditions)
    raw_materials.each do |raw_material|
     rows << {
                "label" => raw_material[:name],
                "id" => raw_material[:id],
                "name" => raw_material[:name],
								"raw_material_category" => raw_material[:material_raw_material_category],
								"base_measure_unit" => raw_material[:material_base_measure_unit],
                "code_response" => (true ? "ok" : "no-ok")
              }
    end
    if raw_materials.empty?
      rows = [{
          "value" => value,
          "label" => "Material no Registrado",
          "code_response" => "no-found"
          }]
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
