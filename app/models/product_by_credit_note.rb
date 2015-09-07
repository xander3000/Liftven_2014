class ProductByCreditNote < ActiveRecord::Base
  attr_accessor :id_temporal
  attr_accessor :note
  
  belongs_to :credit_note
  belongs_to :product


  validates_presence_of :product,:quantity,:unit_price,:total_price
  validates_presence_of :side_dimension_x,:side_dimension_y
  #validates_numericality_of :side_dimension_x,:side_dimension_y,:greater_than => 0

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

end
