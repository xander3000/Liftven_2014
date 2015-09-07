class ProductByBudget < ActiveRecord::Base
  attr_accessor :id_temporal
	attr_accessor :digital_card_id_temporal
  humanize_attributes :product => "Producto",
                      :quantity => "Cantidad",
                      :side_dimension_x => "Ancho",
                      :side_dimension_y => "Largo",
                      :note => "Observaciones",
                      :unit_price => "Precio Unitario",
                      :total_price => "Precio Total",
                      :quantity_page_sheet => "Cant. tripa"

  has_many   :product_component_by_budgets
  has_many		:accesory_component_by_budgets
  belongs_to :budget
  belongs_to :product
	has_one    :digital_card
	has_one :order,:as => :associate

  validates_presence_of :product,:quantity,:side_dimension_x,:side_dimension_y
  validates_presence_of :unit_price,:total_price
  validates_numericality_of :quantity,:greater_than => 0,:allow_nil => true
  #validates_numericality_of :side_dimension_x,:side_dimension_y,:greater_than => 0,:allow_nil => true,:if => Proc.new { |user| user.signup_step > 2}


  before_save :set_value_total_presentation_unit_type_to_use

  #
  # Calcula cuantos unidades de presentation_unit_type se van a usar
  #
  def set_value_total_presentation_unit_type_to_use
      result = product.presentation_unit_type_quantity_to_use(self.quantity,:side_dimension_x => self.side_dimension_x,:side_dimension_y => self.side_dimension_y)
#      quantity_by_presentation_unit_type = product.finished_product.quantity_by_presentation_unit_type(self.side_dimension_x, self.side_dimension_y)
#      div = self.quantity / quantity_by_presentation_unit_type
#      mod = self.quantity % quantity_by_presentation_unit_type
#      result = div + (mod.zero? ? 0 : 1)
    self.total_presentation_unit_type_to_use = result
  end

  #
  # Devuelve la dimesiones del producto
  #

  def side_dimensions
    "#{side_dimension_x} x #{side_dimension_y}"
  end

  #
  # Tienes diemsiones validas
  #
  def has_valid_side_dimensions?
    !side_dimension_x.zero? and !side_dimension_y.zero?
  end

  def self.act
    all.each do |s|
        s.set_value_total_presentation_unit_type_to_use
        s.save
    end
  end

	#Si tiene un diseño digital asociado
	
	def has_digital_card?
		digital_card
	end

  #
  # Muestra los componentes, accesorios y demas, mas cantidad y tamaño si aplica en linea
  #
  def elements_products_description_inline
    components = []
    components_description.each do |product_component_type_id,elements|
      product_component_type = ProductComponentType.find(product_component_type_id.to_s)
      components << "<i>#{product_component_type.name}:</i> #{elements.join(", ")} "
    end
    components << "<i>#{ProductByBudget.human_attribute_name('quantity_page_sheet')}:</i> #{quantity_page_sheet}" if quantity_page_sheet
    components << "<i>Accesorios:</i> #{accesories_description.join(", ")} " if !accesories_description.empty?
    components << "#{product.name}" if components.empty?
    components << "<i>Dimensiones:</i> #{side_dimensions}" if has_valid_side_dimensions?
    components.join("</br>")
  end

  #
  #Obtiene descripcion de los componentes agregados
  #
  def components_description
    product_component_type = {}
    product_component_by_budgets.each do |product_component_by_budget|
      product_component_type_key = product_component_by_budget.product_component_type_id.to_s.to_sym
      product_component_type[product_component_type_key] = [] if product_component_type[product_component_type_key].nil?
      element_class = product_component_by_budget["element_type"].constantize
      element = element_class.find(product_component_by_budget["element_id"])
      if element_class.eql?(PageSizeType) and element.requiere_other_size?
        element_value = "#{side_dimension_x} x #{side_dimension_y}"
      else
        element_value = element.name
      end
      product_component_type[product_component_type_key] << "#{element_class::HUMANIZE_MODEL_NAME}: #{element_value}"
    end
    product_component_type
  end

  #
  #Obtiene descripcion de los accesorios agregafos
  #
  def accesories_description
    accesories = []
    accesory_component_by_budgets.each do |accesory_component_by_budget|
      accesories << "#{accesory_component_by_budget.accessory_component_type.name}"
    end
    accesories
  end

end
