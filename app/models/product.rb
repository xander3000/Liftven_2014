  class Product < ActiveRecord::Base
  LETTERS = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

  attr_accessor :components

  humanize_attributes :reference_code => "Código de referencia",
                      :presentation_type => "Tipo de Presentación",
                      :commercialization_type => "Tipo de Comercialización",
                      :price_definition_type => "Precio definido por",
                      :barcode => "Codigo de barras",
                      :tax_exempt => "¿Exento de IVA?",
                      :instalation_require => "¿Requiere de instalación?",
                      :with_instalation => "Incluir instalaciòn",
                      :finished_product_category_type => "Categoría del producto",
                      :product_type => "Tipo de producto",
                      :components => "Componentes",
                      :is_visible => "¿Mostrar en la Web?",
                      :min_quantity_page_component_type => "Cant. tripa. mínimas",
                      :min_quantity => "Cant. minima a la venta",
                      :dossier_type => "Tipo de tripa",
                      :by_price_definition_set => "Por valor de precio fijado",
											:show_as_shortcut => "¿Ver como Acceso directo?",
											:name => "Nombre del producto"
 
#  belongs_to :finished_product
  belongs_to :presentation_type
  belongs_to :commercialization_type
  belongs_to :finished_product_category_type
  belongs_to :price_definition_type
  belongs_to :product_type
  belongs_to :dossier_type
  has_and_belongs_to_many :accessories,:class_name => "AccessoryComponentType",:join_table => "products_accessories"
  has_and_belongs_to_many :printing_types,:join_table => "printing_types_for_products",:order => "name asc"
  has_and_belongs_to_many :binding_types,:join_table => "binding_types_for_products",:order => "name asc"
  has_and_belongs_to_many :page_size_types,:join_table => "page_size_types_for_products",:order => "name asc"
  has_many :element_for_products
  has_many :price_list_products
  has_many :product_price_definition_set_by_components
  has_many :product_by_budgets
  has_many :product_by_invoices
  has_one :product_price_definition_set
  

  has_attached_file :image,
                    :url  => "/attachments/products/:id/:basename.:extension",
                    :path => ":rails_root/public/attachments/products/:id/:basename.:extension"


  alias_method(:price_lists, :price_list_products)

  validates_presence_of :name,:reference_code,:presentation_type,:commercialization_type,:product_type,:finished_product_category_type,:price_definition_type,:min_quantity
  validates_uniqueness_of :name,:scope => [:product_type_id]
  validates_uniqueness_of :reference_code
  validates_attachment_size :image, :less_than => 2.megabytes,:if => Proc.new { |product| !product.image_file_name.blank? }
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png'],:if => Proc.new { |product| !product.image_file_name.blank? }




	#
	# Nombre y codigo
	#
	def full_name
		"#{reference_code} #{name}"
	end

  #
  # Obtiene el precio del producto
  #

  def price_calculate(quantity,components,accesories_ids,dimension_x,dimension_y,options={})
		options[:to_hash] ||= false
    quantity = quantity.to_i
    dimension_x = dimension_x.to_f
    dimension_y = dimension_y.to_f
		increase_percent = 0
		discount_percent = 0
    #
    # Suma de componentes
    #
      case price_definition_type.tag_name
        when PriceDefinitionType::POR_VALOR_MATERIA_PRIMA
          result = get_price_by_raw_material_product_components(quantity,components,dimension_x,dimension_y,options)
        when PriceDefinitionType::POR_VALOR_PRECIO_POR_COMPONENTES
          result = get_price_by_product_price_definition_set_by_component(quantity,components,dimension_x,dimension_y, options)
        when PriceDefinitionType::POR_VALOR_PRECIO_FIJADO
          result = get_price_by_product_price_definition_set(quantity,components,dimension_x,dimension_y, options)
      end
      success = result["success"]
      total_price = result["total_price"]

    #
    # Suma de accesorios
    #
      result = get_price_by_accesories(accesories_ids, quantity, dimension_x, dimension_y, options)
      success &= result["success"]
      total_price += result["total_price"]

    code_response = success ? "ok" : "no-ok"


		increase_percent = options[:budget][:increase_percent].to_f if(options.has_key?(:budget) and options[:budget].has_key?(:increase_percent))
		discount_percent = options[:budget][:discount_percent].to_f if(options.has_key?(:budget) and options[:budget].has_key?(:discount_percent))

		total_price += total_price*increase_percent/100
		total_price -= total_price*discount_percent/100

    unit_price = total_price.to_f/quantity

		

    result = {"unit_price" => unit_price,"total_price" => total_price,"code_response" => code_response}
		return result if options[:to_hash]
    JSON.generate(result)
  end

      ####################
      # Calculo por RawMaterial
      #
      #
      # Obtiene le precio por cada componente
      #
      def get_price_by_raw_material_product_components(quantity,components,dimension_x,dimension_y,options={})
        accumalte_total_price = 0
        success = false
        components.each do |elements|
          result = get_price_by_raw_material_product_component_elements(quantity, elements, dimension_x, dimension_y, options)
          success = result["success"]
          accumalte_total_price += result["total_price"].to_f if success
        end

        {"total_price" => accumalte_total_price,"success" => success}
      end

      #
      # Obtiene le precio por cada elemento del component
      #
      def get_price_by_raw_material_product_component_elements(quantity,elements,dimension_x,dimension_y,options={})

        success = true
        
        product_component_id = elements[:product_component_id]

        product_component = ProductComponentType.find_by_id(product_component_id)

        quantity_base = quantity

        #Multiplo por la cantidad de elemento <t>quantity_pag</t> si el componente es tipo multiple
        if product_component.is_multiple
          quantity_page = options[:product][:quantity_page_sheet].to_i
            div = quantity_page / dossier_type.convertion
            mod = quantity_page % dossier_type.convertion
            quantity_page = div + (mod.zero? ? 0 : 1)
          quantity *= quantity_page
        end

#        #Multiplico por la cantidad definida segun tipo de componente
#        quantity *= product_component.quantity

        #Multiplico por la cantidad definida segun tipo de presentacion
        quantity *= presentation_type.quantity if product_component.apply_presentation_type?

        raw_material = nil
        color_mode_type = nil
        printing_type = nil
        binding_type = nil
        finish_product_type = nil
        additional_component_type = nil
        page_size_type = nil
        accumalte_total_price = 0
        
        elements["element_type"].each do |element_type_name,value|
        
            if self.class.elements_type_has_a_raw_material_associate(eval(element_type_name))
               raw_material = eval(element_type_name).find_by_id(value).raw_material
            elsif self.class.elements_type_is_color_mode_type(eval(element_type_name))
                color_mode_type = eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_printing_type(eval(element_type_name))
                printing_type = eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_binding_type(eval(element_type_name))
                binding_type = eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_finish_product_type(eval(element_type_name))
                finish_product_type = eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_additional_component_type(eval(element_type_name))
                additional_component_type = eval(element_type_name).find_by_id(value)
            end
        end

        options[:color_mode_type] = color_mode_type
        options[:printing_type] = printing_type || PrintingType.find_by_tag_name(PrintingType::DEFAULT)
        options[:binding_type] = binding_type
        options[:finish_product_type] = finish_product_type
        options[:additional_component_type] = additional_component_type


        if raw_material
          #Suma componetes por 1/4 pliego o por metro cuadrado
            result = get_price_by_raw_material(raw_material,quantity,dimension_x,dimension_y,options)
            success = result["success"]
            accumalte_total_price += result["total_price"].to_f if success
        end
        #Suma otros componentes por unidad
          result = get_price_by_unit_price(quantity_base,dimension_x,dimension_y,options)
          success &= result["success"]
          accumalte_total_price += result["total_price"].to_f if success

        #Suma componnetes adicionales
          result = get_price_by_additional_component(raw_material,quantity_base,dimension_x,dimension_y,options)
          success &= result["success"]
          accumalte_total_price += result["total_price"].to_f if success

        {"total_price" => accumalte_total_price,"success" => success}
      end



      #
      # obtiene el precio del producto por valor de materia prima
      #
      def get_price_by_raw_material(raw_material,quantity,dimension_x,dimension_y,options={})
        options[:by_price_definition_set] = by_price_definition_set

        quantity = quantity.to_i
        dimension_x = dimension_x.to_f
        dimension_y = dimension_y.to_f
        puts "----"
        p raw_material.class
        p "-000"
        p raw_material.raw_material_category
        if raw_material.raw_material_category.is_a_paper_type?
          #Suma componetes por 1/4 pliego
            self.class.get_price_by_raw_material_by_quarter_sheet(raw_material, quantity, dimension_x, dimension_y, options)
        elsif raw_material.raw_material_category.is_a_material_product_type?
            #Suma componetes por metro cuadrado
            self.class.get_price_by_raw_material_by_square_meter(raw_material, quantity, dimension_x, dimension_y, options)
        end 

      end

      #
      # obtiene el precio del producto por valor de materia prima para cuarto de pliego
      #
      def self.get_price_by_raw_material_by_quarter_sheet(raw_material,quantity,dimension_x,dimension_y,options={})
        value_quarter_sheet = self.calculate_max_value_quarter_sheet_required_for_quantity_by_quarter_sheet(quantity,dimension_x,dimension_y,options)
        total_price = 0

        if options[:color_mode_type] and  options[:printing_type]
          #Precio t o t/r por modo de color
          case options[:color_mode_type].tag_name
            when ColorModeType::COLOR

              if AppConfig.min_quarter_sheet >= value_quarter_sheet
                              p "----"
              p value_quarter_sheet
              
                component = PageSizeType.find_by_id(options[:page_size_type])
                result = raw_material.price_definition_set_by_components(quantity, value_quarter_sheet, component,"color",options)
              else
                              p "----"
              p value_quarter_sheet
              
                result = raw_material.value_quarter_sheet_color_raw_material.price_by_value_quarter_sheet(value_quarter_sheet)
              end
            when ColorModeType::MONOCROMATICA
              if AppConfig.min_quarter_sheet >= value_quarter_sheet
                component = PageSizeType.find_by_id(options[:page_size_type])
                result = raw_material.price_definition_set_by_components(quantity, value_quarter_sheet, component,"black",options)
              else
                result = raw_material.value_quarter_sheet_black_raw_material.price_by_value_quarter_sheet(value_quarter_sheet)
              end
            when ColorModeType::SIN_IMPRESION
              result = raw_material.value_quarter_sheet_white_raw_material.price_by_value_quarter_sheet(value_quarter_sheet)
          end

          #Precio def. por tiro o tiro/retiro
          total_price += result["#{options[:printing_type].tag_name}".to_sym]
          total_price *= value_quarter_sheet if AppConfig.min_quarter_sheet < value_quarter_sheet
         end

          #Suma otros componentes asociados
          if options[:finish_product_type] and options[:printing_type]
             total_price += options[:finish_product_type]["amount_#{options[:printing_type].tag_name}".to_sym]*value_quarter_sheet
          end
        
        success = (value_quarter_sheet > 0 ? true : false)

        {"total_price" => total_price,"success" => success}
      end

      #
      # obtiene el precio del producto por valor de materia prima para cuarto de pliego
      #
      def self.get_price_by_raw_material_by_square_meter(raw_material,quantity,dimension_x,dimension_y,options={})
        square_meter = dimension_x*dimension_y
        base_value = raw_material.value_square_meter_raw_material.base_value

        total_price = base_value*square_meter*quantity
 
        success = (total_price > 0 ? true : false)
       
        {"total_price" => total_price,"success" => success}
      end



      #
      #Obtienne el precio de compnetes del tipo unitario
      #
      def get_price_by_unit_price(quantity,dimension_x,dimension_y,options={})
        total_price = 0

          if options[:binding_type]
            result = get_pice_binding_type(options[:binding_type], quantity, dimension_x, dimension_y, options)
            total_price += result["total_price"].to_f
          end
        

        success = true
        
        {"total_price" => total_price,"success" => success}
      end

      #
      #Obtienne el precio de componenets adicinales
      #
      def get_price_by_additional_component(raw_material,quantity,dimension_x,dimension_y,options={})
        total_price = 0

        if options[:additional_component_type] and options[:additional_component_type].amount_per_square_meter
          value_quarter_sheet = self.class.calculate_max_value_quarter_sheet_required_for_quantity_by_quarter_sheet(quantity,options[:additional_component_type].side_dimension_x,options[:additional_component_type].side_dimension_y,options)
          result = raw_material.value_quarter_sheet_color_raw_material.price_by_value_quarter_sheet(value_quarter_sheet)
          total_price += options[:additional_component_type].quantity*result[PrintingType::TIRO.to_sym]*value_quarter_sheet
        end

        success = true

        {"total_price" => total_price,"success" => success}
      end

      #
      #Obtienne el precio de los accesorios seleccionados
      #
      def get_price_by_accesories(accesories_ids,quantity,dimension_x,dimension_y,options={})
        total_price = 0
        accesories_ids.each do |accesory_id|
          accesory = AccessoryComponentType.find_by_id(accesory_id)
          if accesory and accesory.amount_per_unit
            total_price += accesory.amount*quantity
          elsif accesory and accesory.amount_per_quantity
            price_list = accesory.price_list_component_accesories.first(:conditions => ["lower_limit <= ? AND upper_limit >= ?",quantity,quantity])
            total_price += price_list.amount*quantity if price_list
          elsif accesory and accesory.amount_per_square_meter
            square_meter_value = accesory.raw_material.value_square_meter_raw_material.base_value
            total_price += quantity*(dimension_x*dimension_y*square_meter_value)
          elsif   accesory and accesory.amount_per_distance
            #TODO: colocar en parametros
            total_price += quantity*((dimension_x/0.5).round*2+(dimension_y/0.5).round*2)*accesory.amount
          end
        end

        success = true

        {"total_price" => total_price,"success" => success}
      end

      #
      # Obtienne el prcio por BindingType
      #
      def get_pice_binding_type(binding_type,quantity,dimension_x,dimension_y,options={})
        total_price = 0
        success = true

        price_list = binding_type.price_list_component_accesories.first(:conditions => ["lower_limit <= ? AND upper_limit >= ?",quantity,quantity])
        if price_list
          total_price += price_list.amount*quantity
        end
        
        {"total_price" => total_price,"success" => success}
      end

      #
      #Obtienne el precio de componenets extras asociados
      #
      def get_price_by_associates_extra_components(quantity, dimension_x, dimension_y, options={})
        total_price = 0
        #Determinar precio por Componentes asociados
        #
        #
          if options[:finish_product_type] and options[:printing_type]
             total_price += options[:finish_product_type]["amount_#{options[:printing_type].tag_name}".to_sym]
             value_quarter_sheet = self.class.calculate_max_value_quarter_sheet_required_for_quantity_by_quarter_sheet(quantity,dimension_x,dimension_y,options)
             total_price *= value_quarter_sheet
          end
          if options[:binding_type]
            result = get_pice_binding_type(options[:binding_type], quantity, dimension_x, dimension_y, options)
            total_price += result["total_price"].to_f
          end
        #
        #
        ####
        success = true
        {"total_price" => total_price,"success" => success}
      end

        #
        # Calucla la cantidad maxima de product a partir de las dimensiones para
        # presentation_unit_type_measurement del tipo LOGITUDINAL
        #
        def self.calculate_max_value_quarter_sheet_required_for_quantity_by_quarter_sheet(quantity,dimension_x,dimension_y,options={})
          val_1 = calculate_max_quantity_for_dimension_by_quarter_sheet(dimension_x,dimension_y)
          val_2 = calculate_max_quantity_for_dimension_by_quarter_sheet(dimension_y,dimension_x)
          max_val = val_1 > val_2 ? val_1 : val_2

          if !max_val.zero?
            div = quantity / max_val
            mod = quantity % max_val
            quantity = div + (mod.zero? ? 0 : 1)
						quantity = 0 if quantity > AppConfig.max_quarter_sheet
          else
            quantity = 0
          end
          quantity
        end
      #
      ####################

      ###################
      #Calculo por ProductPriceDefinitionSet
      #
      def get_price_by_product_price_definition_set(quantity,components,dimension_x,dimension_y,options={})
        accumalte_total_price = 0
        success = false
        price_definition_set = product_price_definition_set
        if price_definition_set
          success = true
          if commercialization_type.is_metro_cuadrado_type?
            accumalte_total_price += dimension_x*dimension_y*price_definition_set.amount * quantity
          else
            accumalte_total_price += price_definition_set.amount * quantity
          end
          
        end

        result = get_price_by_product_price_definition_set_with_components(quantity, components, dimension_x, dimension_y, options)
        accumalte_total_price += result["total_price"]

        {"total_price" => accumalte_total_price,"success" => success}
      end

      #
      # Calculo el precio para ProductPriceDefinitionSet con componenets
      #
      def get_price_by_product_price_definition_set_with_components(quantity,components,dimension_x,dimension_y,options={})
        accumalte_total_price = 0
        success = true
        components.each do |elements|
          result = get_price_by_product_price_definition_set_with_components_set_elements(quantity, elements, dimension_x, dimension_y, options)
          success = result["success"]
          accumalte_total_price += result["total_price"].to_f if success
        end
         {"total_price" => accumalte_total_price,"success" => success}
      end

      #
      # Obtiene el precio para ProductPriceDefinitionSet por elemntso de los componenets
      #
      def get_price_by_product_price_definition_set_with_components_set_elements(quantity, elements, dimension_x, dimension_y, options)
        total_price = 0
        result = get_separate_element_types(elements["element_type"])
        options = options.merge(result)

        result = get_price_by_associates_extra_components(quantity, dimension_x, dimension_y, options)
        total_price += result["total_price"]
        
        success = true
        {"total_price" => total_price,"success" => success}
      end

      ####################
      # Calculo por ProductPriceDefinitionSetByComponent
      #

        #
        # Determio el precio por componenete
        #
        def get_price_by_product_price_definition_set_by_component(quantity,components,dimension_x,dimension_y,options={})
        accumalte_total_price = 0
        success = false
        components.each do |elements|
          result = get_price_by_product_price_definition_set_elements(quantity, elements, dimension_x, dimension_y, options)
          success = result["success"]
          accumalte_total_price += result["total_price"].to_f if success
        end
        {"total_price" => accumalte_total_price,"success" => success}
      end

      #
      # Determina el precio Por elementos de componentes
      #
      def get_price_by_product_price_definition_set_elements(quantity, elements, dimension_x, dimension_y, options={})
        total_price = 0
        result = get_separate_element_types(elements["element_type"])
        options = options.merge(result)
        
        result = get_price_by_associates_extra_components(quantity, dimension_x, dimension_y, options)
        total_price += result["total_price"]

#        #Determinar precio por Componentes asociados
#        #
#        #
#          if options[:finish_product_type] and options[:printing_type]
#             total_price += options[:finish_product_type]["amount_#{options[:printing_type].tag_name}".to_sym]
#             value_quarter_sheet = self.class.calculate_max_value_quarter_sheet_required_for_quantity_by_quarter_sheet(quantity,dimension_x,dimension_y,options)
#             total_price *= value_quarter_sheet
#          end
#          if options[:binding_type]
#            total_price += options[:binding_type].amount*quantity
#          end
#        #
#        #
#        ####


        #Determinar el precio fijo por  product_price_definition_set
        #
        #
          price_definition_set_by_component = product_price_definition_set_by_components.first(:conditions => ["lower_limit <= ? AND upper_limit >= ?",quantity,quantity])
          if price_definition_set_by_component
            element_types  = get_element_types_with_values_by_product_price_definition_set_by_component(elements)
            result = price_definition_set_by_component

            result =  product_price_definition_set_by_components.first(:conditions => ["lower_limit <= ? AND upper_limit >= ? AND component_id = ? AND component_type = ?",quantity,quantity,element_types[result["component_type"]],result["component_type"]],:joins => [:price_definition_set_by_component_type])
            #Precio def. por tiro o tiro/retiro
            if options[:printing_type]
              total_price += result["amount_#{options[:printing_type].tag_name}".to_sym].to_f * (commercialization_type.is_unidad_type? ? quantity : 1)
              else
              total_price += result["amount_#{PrintingType::DEFAULT}".to_sym].to_f * (commercialization_type.is_unidad_type? ? quantity : 1)
            end
          end
        #
        #
        ###

        success = (total_price > 0 ? true : false)
        {"total_price" => total_price,"success" => success}
      end

      #
      # Obtienen los lementos con sul valores
      #
      def get_element_types_with_values_by_product_price_definition_set_by_component(elements)
        element_types = {}
           elements["element_type"].each do |element_type_name,value|
             element_types[element_type_name] = value
           end
        element_types
      end

  #
  # Obtiene los elementos separados
  #
  def get_separate_element_types(elements_types)
        element_types = {}
        elements_types.each do |element_type_name,value|
            if self.class.elements_type_has_a_raw_material_associate(eval(element_type_name))
               element_types[:raw_material] = eval(element_type_name).find_by_id(value).raw_material
            elsif self.class.elements_type_is_color_mode_type(eval(element_type_name))
                element_types[:color_mode_type] =  eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_printing_type(eval(element_type_name))
                element_types[:printing_type] =  eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_binding_type(eval(element_type_name))
                element_types[:binding_type] =  eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_finish_product_type(eval(element_type_name))
                element_types[:finish_product_type] =  eval(element_type_name).find_by_id(value)
            elsif self.class.elements_type_is_page_size_type(eval(element_type_name))
                page_size_type = eval(element_type_name).find_by_id(value)
            end
        end
        element_types
  end



  #
  # Determina la cantidad maxima por productos que se pueden generar en cuarto de pliego
  #
  def self.calculate_max_quantity_for_dimension_by_quarter_sheet(dimension_x,dimension_y,options={})

    dimension_x = dimension_x.to_f
    dimension_y = dimension_y.to_f

    return 0 if dimension_x.zero? or dimension_y.zero?
    side_rm_x = AppConfig.width_quarter_sheet
    side_rm_y = AppConfig.height_quarter_sheet

    margin_x = AppConfig.margin_cut_width_quarter_sheet
    margin_y = AppConfig.margin_cut_height_quarter_sheet

    if dimension_x < side_rm_x and dimension_y < side_rm_y
      dimension_x += margin_x*2
      dimension_y += margin_y*2
    end
    max_x = 0
    max_y = 0
        
    max_x +=1 while(dimension_x * (max_x+1) <= side_rm_x )
    max_y +=1 while(dimension_y * (max_y+1) <= side_rm_y )
    max_x*max_y;
  end










  ###########################################################################################3

  #
  # Tiene componente multiple
  #
  def has_a_component_type_multiple?
    product_component_types.map(&:is_multiple).include?(true)
  end

  #
  # Tiene componente con definicion de tamaño
  #
  def has_a_component_type_with_dimension?
    elements = element_for_products.map(&:element_type)
    elements.include?("MaterialProductType") or elements.include?("PageSizeType") or commercialization_type.is_metro_cuadrado_type?
  end

  #
  # Busca el precio del producto segun la lista del cliente acorde a una cantidad definida en el ranngo de precios
  #
  def find_price_by_client_list(quantity,client,options={})
    
    quantity = quantity.to_i
    price_amount  = 0

    quantity = presentation_unit_type_quantity_to_use(quantity,options)

    if !quantity.zero?
      price_list = client ? client.price_list : nil
      price_list = PriceList.find_default if (client.nil? or price_list.nil?)
      price_lists = price_list_products.all(:conditions => {:price_list_id => price_list.id})
      price_lists.each do |price_list_item|
        if price_list_item.lower_limit <= quantity and ( price_list_item.upper_limit.nil? or price_list_item.upper_limit >= quantity )
          price_amount = price_list_item.amount
        end
      end
    end

    code_response = (price_amount > 0 ? "ok" : "no-ok")
    total_price = price_amount*quantity
    unit_price = price_amount
    if commercialization_type.is_cantidad_type?
      total_price = price_amount
      unit_price = price_amount/quantity
    end
    {"total_price" => total_price,"unit_price" => unit_price,"code_response" => code_response}
  end

  #
  # Devuelve la categoria a la cual pertenece el producto
  #

  def product_category_type 
    finished_product.finished_product_category_type
  end

  #
  # determina la cantidad de presentation_unit_type real a susar
  #
  def presentation_unit_type_quantity_to_use(quantity,options={})
    real_quantity = 0
    #Productos con dimensiones definidas y de dos diemnsiones
    if commercialization_type.is_cantidad_type? or commercialization_type.is_unidad_type?
      real_quantity = quantity
    else
      #Productos con dos dimensiones
      if commercialization_type.is_tipo_unidad_presentacion_type?
        real_quantity = finished_product.quantity_by_presentation_unit_type(options[:side_dimension_x],options[:side_dimension_y],:quantity => quantity)
        #process =  real_quantity > 0
      end
    end
    real_quantity
  end

  #
  # Busca todos los productos donde el finished_product tenga como categoria el finished_product_category_type
  #

  def self.find_all_by_finished_product_category_type(finished_product_category_type)
    products = []
    products = finished_product_category_type.products
#    finished_product_category_type.finished_products.each do |finished_product|
#      products << finished_product.products
#    end
    products.flatten
  end

  def self.all_for_shortcuts
    all(:conditions => ["show_as_shortcut = ? ",true])
  end
###########################################################################################3

  #
  # Return true si precios del productoson definidos fijamente
  #
  def prices_are_defined_by_value_price_set?
    price_definition_type.is_defined_by_value_price_set?
  end

  #
  # Return true si precios son definidos por materia prima valor
  #
  def prices_are_defined_by_value_raw_material?
    price_definition_type.is_defined_by_value_raw_material?
  end

  #
  # Busca todos los productos donde el finished_product tenga como material el raw_material
  #

  def self.find_all_by_raw_material(raw_material)
    products = []
    raw_material.finished_products.each do |finished_product|
      products << finished_product.products
    end
    products.flatten
  end

  #
  #Busca tdoos los productos por letra segun <m>self.LETTERS</m> odenados alfabeticamente
  #
  def self.all_by_letters
    products_by_leters = {}
    LETTERS.each do |letter|
      products = []
      products = all(:conditions => ["lower(name) LIKE ? ","#{letter}%"])
      products_by_leters[letter.to_sym] = products
    end
    products_by_leters
  end
  
  #
  #Busca de acuerdo al parametro <b>attr</b>, cualquier producto con el valor <b>value<b/>
  #
  def self.find_by_autocomplete(attrs,value,client)
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


    products = all(:conditions => conditions)
    products.each do |product|
      side_dimension_x = 0
      side_dimension_y = 0
      #TODO: Definir tamaños
      fixed_size = false#product.finished_product.fixed_size
      if (fixed_size)
        side_dimension_x = product.finished_product.side_dimension_x
        side_dimension_y = product.finished_product.side_dimension_y
      end
			if product.price_definition_type.tag_name.eql?(PriceDefinitionType::POR_VALOR_PRECIO_FIJADO)
				price_definition_set = product.product_price_definition_set
        if price_definition_set
					price = price_definition_set.amount
				else
					price = 0
				end
			else
				price = "N/D"
			end
      rows << { 
                #"value" => product[attr.to_sym],
                "label" => product[:name],
                "id" => product[:id],
                "name" => product[:name],
                "reference_code" => product[:reference_code],
                "fixed_size" => fixed_size,
                "side_dimension_x" => "",
                "side_dimension_y" => "",
								"price" => price,
								"price_currency" => price.to_f.to_currency,
                "code_response" => (true ? "ok" : "no-ok")
              }
    end
    JSON.generate(rows)
  end

  #
  # Busca los componente del producto de acuerdo al tipo que corresponde
  #
  def product_component_types
    #product_type.product_component_types
    element_for_products.map(&:product_component_type).uniq
  end





  #
  # BEGIN_BLOCK: Busca el componente asociado
  #

    def self.elements_types
      [PaperType,ColorModeType,PrintingType,BindingType,PageSizeType,FinishProductType,MaterialProductType,AdditionalComponentType]
    end
    #BEGIN BLOCK: Behavior Element Types
      def self.elements_type_has_a_raw_material_associate(element_type)
        element_type.instance_methods.include?("raw_material")
      end
      def self.elements_type_is_color_mode_type(element_type)
        [ColorModeType].include?(element_type)
      end
      def self.elements_type_is_printing_type(element_type)
        [PrintingType].include?(element_type)
      end
      def self.elements_type_is_binding_type(element_type)
        [BindingType].include?(element_type)
      end
      def self.elements_type_is_finish_product_type(element_type)
        [FinishProductType].include?(element_type)
      end
      def self.elements_type_is_additional_component_type(element_type)
        [AdditionalComponentType].include?(element_type)
      end
      def self.elements_type_is_page_size_type(element_type)
        [PageSizeType].include?(element_type)
      end
    #END BLOCK: Behavior Element Types

    def paper_types(product_component_type)
      elements_by_product_components_type(PaperType.to_s, product_component_type)
    end


    def printing_types(product_component_type)
      elements_by_product_components_type(PrintingType.to_s, product_component_type)
    end

    def binding_types(product_component_type)
      elements_by_product_components_type(BindingType.to_s, product_component_type)
    end

    def page_size_types(product_component_type)
      elements_by_product_components_type(PageSizeType.to_s, product_component_type)
    end

    def finish_product_types(product_component_type)
      elements_by_product_components_type(FinishProductType.to_s, product_component_type)
    end

    def material_product_types(product_component_type)
      elements_by_product_components_type(MaterialProductType.to_s, product_component_type)
    end

    def additional_component_types(product_component_type)
      elements_by_product_components_type(AdditionalComponentType.to_s, product_component_type)
    end

    def color_mode_types(product_component_type)
      elements_by_product_components_type(ColorModeType.to_s, product_component_type)
    end




  #
  # END_BLOCK: Busca el componente asociado
  #
  
  #
  # Busca los elementos asociados al producto de acuerdo al tipo de componente que lo forma
  #
  def elements_by_product_components_type(element_type,product_component_type)
    element_for_products.all(:conditions => {:product_component_type_id => product_component_type.id,:element_type => element_type}).map(&:element)
  end

  #
  # Busca los elementos asociados al producto de acuerdo al tipo de componente que lo forma 2
  #

  def element_for_products_by_product_components_type(element_type,product_component_type)
    element_for_products.all(:conditions => {:product_component_type_id => product_component_type.id,:element_type => element_type})
  end

  #
  # devuelve true si el producto tiene accesorios
  #
  def has_accesories?
    !accessories.empty?
  end
  
  private





#  has_and_belongs_to_many :paper_types,:join_table => "paper_types_for_products",:order => "name asc"
#  has_and_belongs_to_many :printing_types,:join_table => "printing_types_for_products",:order => "name asc"
#  has_and_belongs_to_many :binding_types,:join_table => "binding_types_for_products",:order => "name asc"
#  has_and_belongs_to_many :page_size_types,:join_table => "page_size_types_for_products",:order => "name asc"




end
