class MeasureChangeDenomination < ActiveRecord::Base
	has_many :cash_bank_cash_count_positions,:class_name => "CashBank::CashCountPosition"
	belongs_to :measure_change_type
	
	#
	# Nombre de la denominacion
	#
	def name
		value.to_currency(false)
	end

	#
	# Nombre de la denominacion
	#
	def fullname
		"#{measure_change_type.name} (#{value.to_currency(false)}) "
	end
end
