class DigitalCardField < ActiveRecord::Base
  attr_accessor :id_temporal
  belongs_to :digital_card
  
end
