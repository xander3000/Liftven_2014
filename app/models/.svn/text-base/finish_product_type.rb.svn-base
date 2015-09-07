class FinishProductType < ActiveRecord::Base
  HUMANIZE_MODEL_NAME = "Tipo de Laminado"
  HUMANIZE_ICON = "note.png"
  has_and_belongs_to_many :product_component_types,:join_table => "product_component_types_for_product_types"

	humanize_attributes  :name => "Nombre",
											:amount_t => "Monto",
											:amount_tr => "¿Monto por Metro cuadrado?"

end
