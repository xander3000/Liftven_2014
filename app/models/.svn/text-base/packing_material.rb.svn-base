class PackingMaterial < ActiveRecord::Base
  belongs_to :presentation_unit_type
  belongs_to :presentation_unit_type_measure
  belongs_to :presentation_unit_type_measurement

  validates_presence_of :presentation_unit_type,:presentation_unit_type_measure,:presentation_unit_type_measurement

  #
  # Nombre completo que contiene nombre + (cantidad + tipo de unidad de presentacion)
  #
  def full_name
    if presentation_unit_type.measurable
      "#{name} de #{quantity} #{presentation_unit_type.name} (#{presentation_unit_type_measure.side_dimension_x}x#{presentation_unit_type_measure.side_dimension_y})"
    else
      "#{name} de #{quantity} #{presentation_unit_type.name}"
    end
  end

	#
	# Retorno con atributos minimos
	#
	def min
		{:id => id,:fullname => full_name}
	end

    
end
