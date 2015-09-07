class CommercializationType < ActiveRecord::Base
  UNIDAD = "unidad"
  CANTIDAD = "cantidad"
  METRO_CUADRADO = "metro_cuadrado"


  validates_presence_of :name,:tag_name
  validates_uniqueness_of :name,:tag_name


  #
  # Retorna <b>true</b> si el objetor es del tipo <b>unidad</b>
  #
  def is_unidad_type?
    tag_name.eql?(UNIDAD)
  end

  #
  # Retorna <b>true</b> si el objetor es del tipo <b>cantidad</b>
  #
  def is_cantidad_type?
    tag_name.eql?(CANTIDAD)
  end

  #
  # Retorna <b>true</b> si el objetor es del tipo <b>metro_cuadrado</b>
  #
  def is_metro_cuadrado_type?
    tag_name.eql?(METRO_CUADRADO)
  end



end
