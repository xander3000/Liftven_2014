class PriceList < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name


  def self.find_default
    first(:conditions => {:default => true})
  end
end
