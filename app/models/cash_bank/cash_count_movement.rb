class CashBank::CashCountMovement < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	humanize_attributes		:total_amount_cash => "Total en efectivo",
												:diference_amount_cash => "Diferencia en efectivo"
												

	belongs_to :cash_bank_daily_cash_closing,:class_name => "CashBank::DailyCashClosing"
	has_many :cash_bank_cash_count_positions,:class_name => "CashBank::CashCountPosition",:foreign_key => "cash_bank_cash_count_movement_id"
	
	validates_presence_of :total_amount_cash,:diference_amount_cash


	#
	# consolidado para le arqueo de caja
	#
	def consolidate_count_positions
		consolidate = {}
		MeasureChangeDenomination.all.each do |measure_change_denomination|
			consolidate[measure_change_denomination.measure_change_type_id] = {:name => measure_change_denomination.measure_change_type.name,:denominations => {}} if !consolidate.has_key?(measure_change_denomination.measure_change_type_id)
			consolidate[measure_change_denomination.measure_change_type_id][:denominations][measure_change_denomination.id] = {:total_amount => 0,:quantity => 0,:name => measure_change_denomination.name}
		end
		cash_bank_cash_count_positions.each do |cash_bank_cash_count_position|
			measure_change_type_id = cash_bank_cash_count_position.measure_change_denomination.measure_change_type_id
			measure_change_denomination_id = cash_bank_cash_count_position.measure_change_denomination_id
			if consolidate[measure_change_type_id][:denominations].has_key?(measure_change_denomination_id)
				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:total_amount] += cash_bank_cash_count_position.total_amount
				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:quantity] += cash_bank_cash_count_position.quantity
#			else
#				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id] = {}
#				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:total_amount] = cash_bank_cash_count_position.total_amount
#				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:quantity] = cash_bank_cash_count_position.quantity
#				consolidate[measure_change_type_id][:denominations][measure_change_denomination_id][:name] = cash_bank_cash_count_position.measure_change_denomination.name
			end
		end
		consolidate
	end

end
