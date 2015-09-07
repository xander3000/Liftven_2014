class RawMaterialPriceDefinitionSetBlackByComponent < ActiveRecord::Base

  humanize_attributes :name => "Nombre",
											:amount_t => "Monto en Tiro",
                      :amount_tr => "Monto en Tiro/Retiro",
                      :base_amount => "¿Monto base?",
											:component => "Componente",
											:raw_material => "Materia prima asociada"
  belongs_to :component,:polymorphic => true
  belongs_to :raw_material#,:class_name => "Material::RawMaterial"

    #
  # Nombre del item
  #
  def name

  end
end
