class ColorModeType < ActiveRecord::Base
  HUMANIZE_MODEL_NAME = "Modo de color"
  HUMANIZE_ICON = "color_wheel.png"
  COLOR = "color"
  MONOCROMATICA = "monocromatica"
  SIN_IMPRESION = "sin_impresion"
  #has_and_belongs_to_many :products,:join_table => "printing_types_for_product_components"


  #
  # Returna true si el objeto es sin impresion
  #
  def is_sin_impresion?
    tag_name.eql?(SIN_IMPRESION)
  end
end
