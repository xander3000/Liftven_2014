class PriceListProduct < ActiveRecord::Base
  belongs_to  :product
  belongs_to  :price_list
  
  belongs_to  :currency_type
            
  validates_presence_of :amount,:lower_limit,:price_list
  validates_numericality_of :amount,:greater_than => 0
  validates_numericality_of :lower_limit,:greater_than => 0,:only_integer => true
  validates_numericality_of :upper_limit,:greater_than => 0,:allow_nil => true,:only_integer => true
  validates_uniqueness_of :amount,:scope => [:lower_limit,:upper_limit,:price_list_id]
end
