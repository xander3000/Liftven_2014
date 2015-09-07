class Backend::ProductsController < Backend::BaseController
  before_filter :current_element_types_selected_clear,:only => [:new,:show,:edit]
  helper_method :current_element_types_selected

  def index
    @products = Product.all_by_letters
  end

  def new
    @product = Product.new
    
    @inventory = Inventory.new
    session[:promociones] = []
    price_list_products_clear
  end

  def create
    @product = Product.new(params[:product])
    @price_list_product = PriceListProduct.new


    @product_price_definition_set_by_component = ProductPriceDefinitionSetByComponent.new
    @product_price_definition_set = ProductPriceDefinitionSet.new

    @inventory = Inventory.new
    @success = @product.valid?
    @product_price_definition_set_by_components = self.price_list_products
    element_for_products = set_element_types_selected
    if @success
      @product.save
      element_for_products.each do |item|
        item.product = @product
        item.save
      end
      @product_price_definition_set_by_components.each do |item|
        item.product = @product
        item.save
      end

      
    end
  end

  def show
    @product = Product.find(params[:id])
    @product_price_definition_set_by_components = @product.product_price_definition_set_by_components
    @product_price_definition_set = @product.product_price_definition_set# || ProductPriceDefinitionSet.new
  end

  def edit
     price_list_products_clear
     @product = Product.find(params[:id])
     @product_price_definition_set_by_component = ProductPriceDefinitionSetByComponent.new
     @product_price_definition_set_by_components = @product.product_price_definition_set_by_components
     @product_price_definition_set = @product.product_price_definition_set || ProductPriceDefinitionSet.new
     set_current_element_types_selected
  end

  def update
    @product = Product.find(params[:id])
    @success = @product.update_attributes(params[:product])
    element_for_products = set_element_types_selected
    #TODO: validar los @product_price_definition_set
    if @success
      @product.element_for_products.clear
      element_for_products.each do |item|
        item.product = @product
        item.save
      end
      if @product.price_definition_type.is_defined_by_value_price_set_by_component_type?
        @product.product_price_definition_set_by_components.clear
        @product_price_definition_set_by_components = self.price_list_products
        @product_price_definition_set_by_components.each do |item|
          item.product = @product
          item.save
        end
      elsif @product.price_definition_type.is_defined_by_value_price_set?
        #@product.product_price_definition_set.clear
        @product_price_definition_set = @product.product_price_definition_set || ProductPriceDefinitionSet.new(:product_id => @product.id)
        @product_price_definition_set.update_attributes(params[:product_price_definition_set])
      end
      @product.reload
    end
  end

  def set_element_types_selected
    element_for_products = []
    if @product
        params[:product_components_id].each do |product_components_id|
        if (!product_components_id.eql?("")) and current_element_types_selected.has_key?("element_type_#{product_components_id}")
          current_element_types_selected["element_type_#{product_components_id}"].each do |class_name,items|
            items[:value_ids].each do |value_id|
              element_for_products << ElementForProduct.new(:product_component_type_id => items[:product_component_type_id],:element_id => value_id,:element_type => class_name)
            end if items[:value_ids]
          end
        end
      end if params[:product_components_id]
    end
    element_for_products
  end

  def select_element_type
    @product_component_type_id = params[:product_component_type_id]#ProductComponentType.find(params[:product_component_type_id])
    @element_type = params[:element_type_name].constantize
  end

  def show_element_type
    @product = Product.find(params[:product_id])
    @product_component_type = ProductComponentType.find(params[:product_component_type_id])
    @element_type = params[:element_type_name].constantize
    @elements_by_product = @product.elements_by_product_components_type(params[:element_type_name], @product_component_type)
  end

  def select_price_definition_set_by_component_type
    @product_price_definition_set_by_component = ProductPriceDefinitionSetByComponent.new
    @price_definition_set_by_component_type = PriceDefinitionSetByComponentType.find_by_id(params[:product_price_definition_set_by_component][:price_definition_set_by_component_type_id].to_i)
    components_types_selected = []
    @component_types = []
    if @price_definition_set_by_component_type
      @product_price_definition_set_by_component.price_definition_set_by_component_type = @price_definition_set_by_component_type
      self.current_element_types_selected.each do |element_type,components|
        component =  components[@price_definition_set_by_component_type.model_relationship]
        components_types_selected << component[:value_ids] if component
      end
      components_types_selected = components_types_selected.flatten.uniq
      @component_types = eval(@price_definition_set_by_component_type.model_relationship)
      @component_types = @component_types.all(:conditions => {:id => components_types_selected})
    end
  end

  def add_element_types
    element_type = {}
    element_type[:name] = "element_type_#{params[:product_component_type_id]}"
    element_type[:class_name] = params[:element_type_name]
    element_type[:values] = params[:element_type_ids]
    element_type[:product_component_type_id] = params[:product_component_type_id]
    self.current_element_types_selected=element_type

  end

  def add_price_list_product
    @success = true
    params[:product_price_definition_set_by_component].each do |component,product_price_definition_set_by_component|
      product_price_definition_set_by_component = ProductPriceDefinitionSetByComponent.new(product_price_definition_set_by_component)
      @success &=  product_price_definition_set_by_component.valid?
    end
   
    if @success
      #TODO: DEbo eleimanar del select la slista de precios con valores...
      params[:product_price_definition_set_by_component].each do |component,product_price_definition_set_by_component|
        self.price_list_products = product_price_definition_set_by_component
      end
      @product_price_definition_set_by_component = ProductPriceDefinitionSetByComponent.new
    end
    @product_price_definition_set_by_components = self.price_list_products
  end

  def add_promocion
    session[:promociones] = [] if session[:promociones].nil?
    session[:promociones] << params[:promocion]
  end

  def autocomplete
    result = Product.find_by_autocomplete(["reference_code","name"],params[:term],self.current_client)
    render :json => result
  end

  def autocomplete_by_code
    result = Product.find_by_autocomplete(["reference_code","name"],params[:term],self.current_client)
    render :json => result
  end
  
  def autocomplete_by_description
    result = Product.find_by_autocomplete("name",params[:term],self.current_client)
    render :json => result
  end

  def select_product_component_types
    @product_type = ProductType.find_by_id(params[:product][:product_type_id].to_i)
    @product_component_types = @product_type.product_component_types if @product_type
  end

  def select_price_definition
    product = Product.find_by_id(params[:product_id].to_i)
    @price_definition = PriceDefinitionType.find_by_id(params[:product][:price_definition_type_id].to_i)
    case @price_definition.tag_name
      when PriceDefinitionType::POR_VALOR_PRECIO_FIJADO
        @product_price_definition_set = ProductPriceDefinitionSet.new
      when   PriceDefinitionType::POR_VALOR_PRECIO_POR_COMPONENTES
        @product_price_definition_set_by_component = ProductPriceDefinitionSetByComponent.new
        if product
          product_price_definition_set_by_component = product.product_price_definition_set_by_components.first
          @product_price_definition_set_by_component = product_price_definition_set_by_component ? product_price_definition_set_by_component : ProductPriceDefinitionSetByComponent.new
        end
    end
    
    
  end

  def check_product_component_types
    @product_component_types = []
    @product_component_types =  ProductComponentType.find_all_by_id(params[:product_components_ids])
    @product = Product.find_by_id(params[:product_id].to_i) || Product.new
  end

  def select_prices
    @product = Product.find_by_id(params[:product][:product_id])
    components = []
    params[:product_component_id].each do |product_component_id,elements|
      components << {:product_component_id => product_component_id}.merge(elements)
    end if params[:product_component_id]

    accesories_ids = params[:accessories_ids] ? params[:accessories_ids] : []

    quantity = params[:product][:quantity]
    result = @product.price_calculate(quantity,components,accesories_ids,params[:product][:side_dimension_x],params[:product][:side_dimension_y],params)
    render :json => result
  end

  def price_list_products=(price_list_product)
    session[:products_price_list_products] = [] if session[:products_price_list_products].nil?
    session[:products_price_list_products] << price_list_product unless session[:products_price_list_products].include?(price_list_product)
  end

  def price_list_products
    price_list_products = []
    session[:products_price_list_products] = [] if session[:products_price_list_products].nil?
    session[:products_price_list_products].each do  |price_list_product|
      price_list_products << ProductPriceDefinitionSetByComponent.new(price_list_product)
    end
    price_list_products
  end

  def price_list_products_clear
    session[:products_price_list_products] = []
  end
  


  def current_element_types_selected
    session[:current_element_types_selected] ? session[:current_element_types_selected] : {}
  end

  protected

    def current_element_types_selected=(element_type)
      session[:current_element_types_selected][element_type[:name]] = {} if  session[:current_element_types_selected][element_type[:name]].nil?
      session[:current_element_types_selected][element_type[:name]][element_type[:class_name]] = {}
      session[:current_element_types_selected][element_type[:name]][element_type[:class_name]][:value_ids] = element_type[:values]
      session[:current_element_types_selected][element_type[:name]][element_type[:class_name]][:product_component_type_id] = element_type[:product_component_type_id]
    end

  def set_current_element_types_selected
    @product.product_component_types.each do |product_component_type|
      
      element_type = {}
      element_type[:name] = "element_type_#{product_component_type.id}"
      @product.element_for_products.map(&:element_type).uniq.each do |element_for_product|
        element_type[:class_name] = element_for_product
        element_type[:values] = @product.elements_by_product_components_type(element_for_product, product_component_type).map(&:id).map(&:to_s)
        element_type[:product_component_type_id] = product_component_type.id
        self.current_element_types_selected=element_type
      end
    end
  end

  def current_element_types_selected_clear
    session[:current_element_types_selected] = {}
  end

  def set_title
    @title = "Productos y Servicios"
  end

end
