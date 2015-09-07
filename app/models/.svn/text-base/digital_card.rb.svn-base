class DigitalCard < ActiveRecord::Base
  SESSION_KEY_REFERENCE = :current_session_designs
  attr_accessor :id_temporal
  has_many :digital_card_fields
  belongs_to :product_by_budget
	has_one :doc,:as => :category

end
