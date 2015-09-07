class Accounting::LedgerType < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end


	#
	# Buscar tipo de libro
	#
	def self.first_per_bank
		self.find_by_tag_name("banco")
	end

	#
	# Buscar tipo de libro caja
	#
	def self.first_per_caja
		self.find_by_tag_name("caja")
	end
  
  #
	# Buscar tipo de libro interno
	#
	def self.first_per_interno
		self.find_by_tag_name("interno")
	end
  
  
end
