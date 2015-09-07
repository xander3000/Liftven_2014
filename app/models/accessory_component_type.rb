class AccessoryComponentType < ActiveRecord::Base

	humanize_attributes  :name => "Nombre",
											:amount => "Monto",
											:amount_per_square_meter => "¿Monto por Metro cuadrado?",
											:amount_per_square_lineal => "¿Monto por metro lineal?",
											:amount_per_quarter_sheet => "¿Monto or cuarto de pliego?",
											:amount_per_quantity => "¿Monto por cantidad?",
											:amount_per_distance => "¿Monto  por distancia?",
											:raw_material => "Materia prima asociada"


  belongs_to :raw_material#,:class_name => "Material::RawMaterial"
  has_and_belongs_to_many :products,:join_table => "products_accessories"
  has_many :price_list_component_accesories,:conditions => {:active => true},:as =>:component_accesory
end
