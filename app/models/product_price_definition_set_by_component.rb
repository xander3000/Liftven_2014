class ProductPriceDefinitionSetByComponent < ActiveRecord::Base

  humanize_attributes :price_definition_set_by_component_type => "Definido por",
                      :amount_t => "Valor por Tiro",
                      :amount_tr => "Valor por Tiro/Retiro",
                      :lower_limit => "Cant. minima",
                      :upper_limit => "Cant. maxima",
                      :price_list => "Lista precio"



  belongs_to :product
  belongs_to :price_definition_set_by_component_type
  belongs_to :price_list
  belongs_to :component,:polymorphic => true

  validates_presence_of :price_definition_set_by_component_type,:amount_t,:amount_tr,:lower_limit,:price_list
  
  after_create :set_maximun_upper_limit


  #
  # Define un mvalor maximo si el valor es infinito
  #
  def set_maximun_upper_limit
    if upper_limit.nil? || upper_limit.zero?
      update_attribute(:upper_limit, 2147483647)
    end
  end
  
end
