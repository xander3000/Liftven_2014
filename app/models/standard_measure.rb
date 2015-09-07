class StandardMeasure < ActiveRecord::Base
  humanize_attributes :id => "Medidas"


  #
  # retorna side_dimension_x x side_dimension_y
  #
  def value
    "#{side_dimension_x}x#{side_dimension_y}"
  end
end
