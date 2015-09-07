class ProductPriceDefinitionSet < ActiveRecord::Base
  humanize_attributes :amount => "Monto / Valor",
                      :lower_limit => "Cant. minima",
                      :upper_limit => "Cant. maxima",
                      :price_list => "Lista precio"

  belongs_to :product
  belongs_to :price_list


  validates_presence_of :amount,:lower_limit,:price_list
  
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
