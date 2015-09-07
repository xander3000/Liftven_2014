class PrintingType < ActiveRecord::Base
  HUMANIZE_MODEL_NAME = "Tipo de Impresión"
  HUMANIZE_ICON = "printer_empty.png"

  TIRO = "t"
  TIRO_RETIRO = "tr"
  DEFAULT = TIRO
  
  has_and_belongs_to_many :products,:join_table => "printing_types_for_product_components"


  #
  # registro popr defecto
  #
  def self.default
    find_by_tag_name(DEFAULT)
  end
end
