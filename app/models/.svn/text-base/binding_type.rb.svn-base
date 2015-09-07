class BindingType < ActiveRecord::Base
  HUMANIZE_MODEL_NAME = "Tipo de Encuadernación"
  HUMANIZE_ICON = "report.png"
  has_and_belongs_to_many :products,:join_table => "printing_types_for_products"
  has_many :price_list_component_accesories,:conditions => {:active => true},:as =>:component_accesory
end
