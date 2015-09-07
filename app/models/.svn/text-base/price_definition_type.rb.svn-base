class PriceDefinitionType < ActiveRecord::Base
  POR_VALOR_MATERIA_PRIMA = "valor_materia_prima"
  POR_VALOR_PRECIO_POR_COMPONENTES = "precio_por_componentes"
  POR_VALOR_PRECIO_FIJADO = "precio_fijado"


  #
  # si es por cuarto de pliego
  #
  def is_defined_by_value_raw_material?
    tag_name.eql?(POR_VALOR_MATERIA_PRIMA)
  end

  #
  # si es por precio fijado
  #
  def is_defined_by_value_price_set?
    tag_name.eql?(POR_VALOR_PRECIO_FIJADO)
  end
  #
  # si es por precio por componentes
  #
  def is_defined_by_value_price_set_by_component_type?
    tag_name.eql?(POR_VALOR_PRECIO_POR_COMPONENTES)
  end
end
