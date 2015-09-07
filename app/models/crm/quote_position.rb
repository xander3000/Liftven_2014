class Crm::QuotePosition < ActiveRecord::Base
	def self.table_name_prefix
    'crm_'
  end



	attr_accessor :product_code,
								:id_temporal
	
		humanize_attributes		:product => "Producto / servicio",
													:quantity => "Cantidad"


	belongs_to :product
	belongs_to :crm_quote,:class_name => "Crm::Quote"


	validates_presence_of :product,:quantity

end
