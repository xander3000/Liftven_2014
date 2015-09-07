class PriceListComponentAccesory < ActiveRecord::Base

	humanize_attributes :component_accesory => "Accesorio",
											:amount => "Monto",
											:lower_limit => "Cant. Mínima",
											:upper_limit => "Cant. Máxima",
											:name => "Nombre"


  belongs_to :component_accesory,:polymorphic => true

	#
	# Nombre del componente
	#
	def name
		component_accesory.name
	end
end
