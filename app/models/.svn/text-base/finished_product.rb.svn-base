class FinishedProduct < ActiveRecord::Base

  humanize_attributes :finished_product_category_type => "Categoria",
                      :raw_material => "Material",
                      :presentation_unit_type => "Tipo de unidad de presentación",
                      :fixed_size => "Tamaño Fijo",
                      :side_dimension_x => "AnchoxLargo",
                      :side_dimension_y => "Largo",
                      :presentation_unit_type_quantity => "Cantidad por Tipo de unidad de presentación"


  belongs_to :finished_product_category_type
  belongs_to :raw_material#,:class_name => "Material::RawMaterial"
  belongs_to :presentation_unit_type
  has_many :products, :order => "name ASC"


  validates_presence_of :finished_product_category_type,:raw_material,:presentation_unit_type
  validates_presence_of :side_dimension_x,:side_dimension_y,:presentation_unit_type_quantity, :if => Proc.new { |finished_product| finished_product.fixed_size }
  validates_numericality_of :side_dimension_x,:side_dimension_y,:presentation_unit_type_quantity,:allow_nil => true

  before_create :set_values_for_fixed_size


  #
  # Define valores por defecto si el las dimensiones son variables para
  # <b>side_dimension_x</b>,<b>side_dimension_y</b> y <b>presentation_unit_type_quantity</b>
  #
  def set_values_for_fixed_size
    self.side_dimension_x = 0
    self.side_dimension_y = 0
    self.presentation_unit_type_quantity = 0
  end


  #
  # Nombre completo con el tipo de raw_material asociado
  #
  def full_name
    "#{finished_product_category_type.full_name} (#{raw_material.name})"
  end


  #
  # Determina de acuerdo al tamaño cuantos productos terminados se pueden generar
  #
  def quantity_by_presentation_unit_type(dimension_x,dimension_y,options={})
    dimension_x = dimension_x.to_f
    dimension_y = dimension_y.to_f
    case presentation_unit_type_measurement.name
      when PresentationUnitTypeMeasurement::SUPERFICIAL
        calculate_max_quantity_for_superficie_presentation_unit_type_measurement(dimension_x,dimension_y)
      when PresentationUnitTypeMeasurement::LOGITUDINAL
        calculate_max_quantity_for_longitudinal_presentation_unit_type_measurement(dimension_x,dimension_y,options)
      else
        0
    end
  end


  private


    #
    # devuelve el presentation_unit_type_measurement de acuerdo al raw_material
    #
    def presentation_unit_type_measurement
      raw_material.packing_material.presentation_unit_type_measurement
    end

    #
    # Calucla la cantidad maxima de finished_product a partir de las dimensiones para
    # presentation_unit_type_measurement del tipo SUPERFICIAL
    #

    def calculate_max_quantity_for_superficie_presentation_unit_type_measurement(dimension_x,dimension_y)
      dimension_x*dimension_y
    end

    #
    # Calucla la cantidad maxima de finished_product a partir de las dimensiones para
    # presentation_unit_type_measurement del tipo LOGITUDINAL
    #

    def calculate_max_quantity_for_longitudinal_presentation_unit_type_measurement(dimension_x,dimension_y,options={})
      quantity = options[:quantity] || 0
      val_1 = calculate_max_quantity(dimension_x,dimension_y)
      val_2 = calculate_max_quantity(dimension_y,dimension_x)
      max_val = val_1 > val_2 ? val_1 : val_2

      if !max_val.zero?
        div = quantity / max_val
        mod = quantity % max_val
        quantity = div + (mod.zero? ? 0 : 1)
      else
        quantity = 0
      end
      quantity
    end

    #
    # Determina la cantidad maxima por finished_product a partir de las dimensiones
    #
    def calculate_max_quantity(dimension_x,dimension_y)
      return 0 if dimension_x.zero? or dimension_y.zero?
      border_x = 1
      border_y = 1
      max_x = 0
      max_y = 0
      side_rm_x = presentation_unit_type.presentation_unit_type_measure.side_dimension_x
      side_rm_y = presentation_unit_type.presentation_unit_type_measure.side_dimension_y
      while(dimension_x * (max_x+1) <= side_rm_x )
        max_x +=1
      end

      while(dimension_y * (max_y+1) <= side_rm_y )
        max_y +=1
      end
      max_x*max_y;
    end
end
