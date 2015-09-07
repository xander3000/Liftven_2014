class ProductComponentType < ActiveRecord::Base
  SIMPLE = "simple"
  PORTADA_CONTRAPORTADA = "portada_contraportada"
  TRIPA = "tripa"


  has_and_belongs_to_many :product_types,:join_table => "product_component_types_for_product_types"
  has_and_belongs_to_many :paper_types,:join_table => "paper_types_for_product_components"
  has_and_belongs_to_many :printing_types,:join_table => "printing_types_for_product_components"

  #
  # Devuelve tru si el tipo es simple
  #
  def is_simple?
    tag_name.eql?(SIMPLE)
  end

  #
  # Devuelve tru si el tipo es portada_contraportada
  #
  def is_portada_contraportada?
    tag_name.eql?(PORTADA_CONTRAPORTADA)
  end

  #
  # Devuelve true si el tipo es tripa
  #
  def is_tripa?
    tag_name.eql?(TRIPA)
  end

  #
  # Devuekve tru si requiere aplicar el quantity de presentation_types
  #
  def apply_presentation_type?
    [SIMPLE,PORTADA_CONTRAPORTADA].include?(tag_name)
  end

end
