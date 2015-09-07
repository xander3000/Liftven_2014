class AdditionalComponentType < ActiveRecord::Base
  humanize_attributes  :name => "Nombre"

	HUMANIZE_MODEL_NAME = "Componente Adicional"
  HUMANIZE_ICON = "box.png"

end
