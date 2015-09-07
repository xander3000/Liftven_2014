class CashBank::InvolvementType < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	#
	# Requiere comprimiso
	#
	def require_commitment?
		["ccp","dco"].include?(tag_name.downcase)
	end

	#
	# Debengado y cobrado
	#
	def self.accrued_collected
		first(:conditions => {:tag_name => "dco"})
	end

end
